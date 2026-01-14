# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Ensure default admin user exists (for standalone Junction installation)
def create_default_admin_user
  return if Junction::User.exists?(email_address: "admin@example.com")

  Junction::User.create!(
    display_name: "Administrator",
    email_address: "admin@example.com",
    password: "passWord1!",
    password_confirmation: "passWord1!"
  )

  puts "✓ Created default admin user: admin@example.com (password: passWord1!)"
end

create_default_admin_user

def import_apis(path)
  return unless File.exist?(Rails.root.join(path, 'apis.yaml'))

  YAML.load_file(Rails.root.join(path, 'apis.yaml'), symbolize_names: true).each do |api|
    next if Api.find_by(name: api[:name])

    Rails.logger.info "Creating API #{api[:name]}"
    api[:system] = System.find_by(name: api[:system]) if api[:system].present?
    api[:owner] = Group.find_by(name: api[:owner]) if api[:owner].present?
    api[:dependent_components] = []
    api[:dependent_resources] = []

    (api.delete(:dependencies) || []).each do |dependency|
      type, name = dependency.split(':', 2)
      api["dependent_#{type}s".to_sym] << type.capitalize.constantize.find_by(name: name.strip)
    end

    Api.create(api)
  end
end

def import_components(path)
  return unless File.exist?(Rails.root.join(path, 'components.yaml'))

  YAML.load_file(Rails.root.join(path, 'components.yaml'), symbolize_names: true).each do |component|
    next if Component.find_by(name: component[:name])

    Rails.logger.info "Creating component #{component[:name]}"
    component[:system] = System.find_by(name: component[:system]) if component[:system].present?
    component[:owner] = Group.find_by(name: component[:owner]) if component[:owner].present?
    component[:dependent_components] = []
    component[:dependent_resources] = []

    (component.delete(:dependencies) || []).each do |dependency|
      type, name = dependency.split(':', 2)
      entity = type.capitalize.constantize.find_by(name: name.strip)
      component["dependent_#{type}s".to_sym] << entity if entity
    end

    Component.create(component)
  end
end

def import_domains(path)
  return unless File.exist?(Rails.root.join(path, 'domains.yaml'))

  YAML.load_file(Rails.root.join(path, 'domains.yaml'), symbolize_names: true).each do |domain|
    next if Domain.find_by(name: domain[:name])

    Rails.logger.info "Creating domain #{domain[:name]}"
    Domain.create(domain)
  end
end

def import_groups(path)
  return unless File.exist?(Rails.root.join(path, 'groups.yaml'))

  YAML.load_file(Rails.root.join(path, 'groups.yaml'), symbolize_names: true).each do |group|
    next if Group.find_by(name: group[:name])

    Rails.logger.info "Creating user #{group[:name]}"
    group.fetch(:members, []).map! do |member|
      Junction::User.find_by(email_address: member)
    end

    Group.create(group)
  end
end

def import_resources(path)
  return unless File.exist?(Rails.root.join(path, 'resources.yaml'))

  YAML.load_file(Rails.root.join(path, 'resources.yaml'), symbolize_names: true).each do |resource|
    next if Resource.find_by(name: resource[:name])

    Rails.logger.info "Creating resource #{resource[:name]}"
    resource[:system] = System.find_by(name: resource[:system]) if resource[:system].present?
    resource[:owner] = Group.find_by(name: resource[:owner]) if resource[:owner].present?
    Resource.create(resource)
  end
end

def import_systems(path)
  return unless File.exist?(Rails.root.join(path, 'systems.yaml'))

  YAML.load_file(Rails.root.join(path, 'systems.yaml'), symbolize_names: true).each do |system|
    next if System.find_by(name: system[:name])

    Rails.logger.info "Creating system #{system[:name]}"
    system[:domain] = Domain.find_by(name: system[:domain]) if system[:domain].present?
    system[:owner] = Group.find_by(name: system[:owner]) if system[:owner].present?
    System.create(system)
  end
end

def import_users(path)
  return unless File.exist?(Rails.root.join(path, 'users.yaml'))

  YAML.load_file(Rails.root.join(path, 'users.yaml'), symbolize_names: true).each do |user|
    next if Junction::User.find_by(email_address: user[:email_address])

    Rails.logger.info "Creating user #{user[:display_name]}"
    user[:password] = random_password
    entity = Junction::User.create(user)

    unless entity.persisted?
      puts "Failed to create user #{user[:display_name]}"
    end
  end
end

def random_password(length: 64)
  chars = [ *'0'..'9', *'a'..'z', *'A'..'Z', '+', '$', '@', '!', '#' ]
  length.times.map do
    chars.sample
  end.join
end

org = "sample"
path = Rails.root.join('db', 'seeds', org)
if Rails.env.development?
  import_users(path)
  import_groups(path)
  import_domains(path)
  import_systems(path)
  import_resources(path)
  import_components(path)
  import_apis(path)
end
