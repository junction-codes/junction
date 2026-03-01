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

def create_system_roles
  [
    {
      name: Junction::Permissions::UserPermissions::ADMIN_ROLE_NAME,
      description: "Super user role with all permissions."
    },
    {
      name: Junction::Permissions::UserPermissions::READ_ALL_ROLE_NAME,
      description: "Global read-only role with all read permissions."
    }
  ].each do |role|
    role[:system] = true
    Junction::Role.find_or_initialize_by(name: role[:name]).update!(role)
  end
end

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

def create_default_role_groups
  admin_name = Junction::Permissions::UserPermissions::ADMIN_ROLE_NAME
  read_all_name = Junction::Permissions::UserPermissions::READ_ALL_ROLE_NAME

  Junction::Group.find_or_create_by!(name: "Junction Admins") do |g|
    g.description = "Default group for administrators. Members receive the Admin role."
    g.annotations = { "junction.codes/role" => admin_name }
  end

  Junction::Group.find_or_create_by!(name: "Junction Readers") do |g|
    g.description = "Default group for read-only access. Members receive the Read all role."
    g.annotations = { "junction.codes/role" => read_all_name }
  end
end

def add_default_admin_to_junction_admins
  admin_user = Junction::User.find_by(email_address: "admin@example.com")
  junction_admins = Junction::Group.find_by(name: "Junction Admins")
  return unless admin_user && junction_admins

  Junction::GroupMembership.find_or_create_by!(user: admin_user, group: junction_admins)
end

# TODO: Create an importer server to handle this logic in a more robust way.
def import_apis(path)
  return unless File.exist?(Rails.root.join(path, 'apis.yaml'))

  YAML.load_file(Rails.root.join(path, 'apis.yaml'), symbolize_names: true).each do |api|
    next if Junction::Api.find_by(name: api[:name])

    Rails.logger.info "Creating API #{api[:name]}"
    api[:system] = Junction::System.find_by(name: api[:system]) if api[:system].present?
    api[:owner] = Junction::Group.find_by(name: api[:owner]) if api[:owner].present?
    api[:dependent_components] = []
    api[:dependent_resources] = []

    (api.delete(:dependencies) || []).each do |dependency|
      type, name = dependency.split(':', 2)
      api["dependent_#{type}s".to_sym] << Junction.const_get(type.capitalize).find_by(name: name.strip)
    end

    Junction::Api.create(api)
  end
end

def import_components(path)
  return unless File.exist?(Rails.root.join(path, 'components.yaml'))

  YAML.load_file(Rails.root.join(path, 'components.yaml'), symbolize_names: true).each do |component|
    next if Junction::Component.find_by(name: component[:name])

    Rails.logger.info "Creating component #{component[:name]}"
    component[:system] = Junction::System.find_by(name: component[:system]) if component[:system].present?
    component[:owner] = Junction::Group.find_by(name: component[:owner]) if component[:owner].present?
    component[:dependent_components] = []
    component[:dependent_resources] = []

    (component.delete(:dependencies) || []).each do |dependency|
      type, name = dependency.split(':', 2)
      entity = Junction.const_get(type.capitalize).find_by(name: name.strip)
      component["dependent_#{type}s".to_sym] << entity if entity
    end

    Junction::Component.create(component)
  end
end

def import_domains(path)
  return unless File.exist?(Rails.root.join(path, 'domains.yaml'))

  YAML.load_file(Rails.root.join(path, 'domains.yaml'), symbolize_names: true).each do |domain|
    next if Junction::Domain.find_by(name: domain[:name])

    Rails.logger.info "Creating domain #{domain[:name]}"
    Junction::Domain.create(domain)
  end
end

def import_groups(path)
  return unless File.exist?(Rails.root.join(path, 'groups.yaml'))

  YAML.load_file(Rails.root.join(path, 'groups.yaml'), symbolize_names: true).each do |group|
    next if Junction::Group.find_by(name: group[:name])

    Rails.logger.info "Creating user #{group[:name]}"
    group.fetch(:members, []).map! do |member|
      Junction::User.find_by(email_address: member)
    end

    Junction::Group.create(group)
  end
end

def import_resources(path)
  return unless File.exist?(Rails.root.join(path, 'resources.yaml'))

  YAML.load_file(Rails.root.join(path, 'resources.yaml'), symbolize_names: true).each do |resource|
    next if Junction::Resource.find_by(name: resource[:name])

    Rails.logger.info "Creating resource #{resource[:name]}"
    resource[:system] = Junction::System.find_by(name: resource[:system]) if resource[:system].present?
    resource[:owner] = Junction::Group.find_by(name: resource[:owner]) if resource[:owner].present?
    Junction::Resource.create(resource)
  end
end

def import_systems(path)
  return unless File.exist?(Rails.root.join(path, 'systems.yaml'))

  YAML.load_file(Rails.root.join(path, 'systems.yaml'), symbolize_names: true).each do |system|
    next if Junction::System.find_by(name: system[:name])

    Rails.logger.info "Creating system #{system[:name]}"
    system[:domain] = Junction::Domain.find_by(name: system[:domain]) if system[:domain].present?
    system[:owner] = Junction::Group.find_by(name: system[:owner]) if system[:owner].present?
    Junction::System.create(system)
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

create_system_roles

if Rails.env.development?
  create_default_admin_user
  create_default_role_groups
  add_default_admin_to_junction_admins

  path = Junction::Engine.seed_data_path(ENV.fetch("JUNCTION_SEED_ORG", "sample"))
  import_users(path)
  import_groups(path)
  import_domains(path)
  import_systems(path)
  import_resources(path)
  import_components(path)
  import_apis(path)
end
