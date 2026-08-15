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
      title: "Admin",
      description: "Super user role with all permissions."
    },
    {
      name: Junction::Permissions::UserPermissions::READ_ALL_ROLE_NAME,
      title: "Read All",
      description: "Global read-only role with all read permissions."
    }
  ].each do |role|
    r = Junction::Role.find_or_initialize_by(name: role[:name])
    r.title = role[:title]
    r.description = role[:description]
    r.system = true
    r.save!
  end
end

# Ensure default admin user exists (for standalone Junction installation)
def create_default_admin_user
  return if Junction::User.exists?(email_address: "admin@example.com")

  Junction::User.create!(
    title: "Administrator",
    name: "admin",
    email_address: "admin@example.com",
    password: "passWord1!",
    password_confirmation: "passWord1!"
  )

  puts "✓ Created default admin user: admin@example.com (password: passWord1!)"
end

def create_default_role_groups
  admin_name = Junction::Permissions::UserPermissions::ADMIN_ROLE_NAME
  read_all_name = Junction::Permissions::UserPermissions::READ_ALL_ROLE_NAME

  Junction::Group.find_or_create_by!(name: "junction-admins", namespace: "default") do |g|
    g.title = "Junction Admins"
    g.description = "Default group for administrators. Members receive the Admin role."
    g.annotations = { "junction.codes/role" => admin_name }
  end

  Junction::Group.find_or_create_by!(name: "junction-readers", namespace: "default") do |g|
    g.title = "Junction Readers"
    g.description = "Default group for read-only access. Members receive the Read all role."
    g.annotations = { "junction.codes/role" => read_all_name }
  end
end

def add_default_admin_to_junction_admins
  admin_user = Junction::User.find_by(
    name: Junction::Permissions::UserPermissions::ADMIN_ROLE_NAME,
    namespace: "default"
  )
  junction_admins = Junction::Group.find_by(name: "junction-admins", namespace: "default")
  return unless admin_user && junction_admins

  Junction::GroupMembership.find_or_create_by!(user: admin_user, group: junction_admins)
end

# Finds an entity referenced by another.
#
# References may be namespace qualified (e.g. `development/guest`). Unqualified
# references are looked up in the namespace of the entity holding the reference,
# falling back to the default namespace.
#
# @param model [Class] Model the reference points at.
# @param reference [String] Referenced entity name, optionally namespace
#   qualified.
# @param namespace [String] Namespace of the entity holding the reference.
# @return [ActiveRecord::Base, nil] The referenced entity, if found.
def find_reference(model, reference, namespace)
  qualifier, name = reference.to_s.split('/', 2)
  return model.find_by(namespace: qualifier, name: name) if name.present?

  model.find_by(namespace: namespace, name: reference) ||
    model.find_by(namespace: Junction::Sluggable::DEFAULT_NAMESPACE, name: reference)
end

# TODO: Create an importer server to handle this logic in a more robust way.
def import_apis(path)
  return unless File.exist?(Rails.root.join(path, 'apis.yaml'))

  YAML.load_file(Rails.root.join(path, 'apis.yaml'), symbolize_names: true).each do |api|
    namespace = api.fetch(:namespace, "default")
    next if Junction::Api.find_by(name: api[:name], namespace: namespace)

    Rails.logger.info "Creating API #{api[:title]}"
    api[:system] = find_reference(Junction::System, api[:system], namespace) if api[:system].present?
    api[:owner] = find_reference(Junction::Group, api[:owner], namespace) if api[:owner].present?

    Junction::Api.create(api.except(:dependencies))
  end
end

def import_components(path)
  return unless File.exist?(Rails.root.join(path, 'components.yaml'))

  YAML.load_file(Rails.root.join(path, 'components.yaml'), symbolize_names: true).each do |component|
    namespace = component.fetch(:namespace, "default")
    next if Junction::Component.find_by(name: component[:name], namespace: namespace)

    Rails.logger.info "Creating component #{component[:title]}"
    component[:system] = find_reference(Junction::System, component[:system], namespace) if component[:system].present?
    component[:owner] = find_reference(Junction::Group, component[:owner], namespace) if component[:owner].present?

    Junction::Component.create(component.except(:dependencies))
  end
end

def import_domains(path)
  return unless File.exist?(Rails.root.join(path, 'domains.yaml'))

  domains = YAML.load_file(Rails.root.join(path, 'domains.yaml'), symbolize_names: true)

  domains.each do |domain|
    namespace = domain.fetch(:namespace, "default")
    next if Junction::Domain.find_by(name: domain[:name], namespace: namespace)

    Rails.logger.info "Creating domain #{domain[:title]}"
    Junction::Domain.create(domain.except(:parent))
  end

  domains.each do |domain|
    next if domain[:parent].blank?

    namespace = domain.fetch(:namespace, "default")
    record = Junction::Domain.find_by(name: domain[:name], namespace: namespace)
    parent = find_reference(Junction::Domain, domain[:parent], namespace)

    next unless record && parent

    record.update!(parent_id: parent.id)
  end
end

def import_groups(path)
  return unless File.exist?(Rails.root.join(path, 'groups.yaml'))

  groups = YAML.load_file(Rails.root.join(path, 'groups.yaml'), symbolize_names: true)

  groups.each do |group|
    namespace = group.fetch(:namespace, "default")
    next if Junction::Group.find_by(name: group[:name], namespace: namespace)

    Rails.logger.info "Creating group #{group[:title]}"
    group[:members] = group.fetch(:members, []).filter_map do |member|
      find_reference(Junction::User, member, namespace)
    end

    Junction::Group.create(group.except(:parent))
  end

  groups.each do |group|
    next if group[:parent].blank?

    namespace = group.fetch(:namespace, "default")
    record = Junction::Group.find_by(name: group[:name], namespace: namespace)
    parent = find_reference(Junction::Group, group[:parent], namespace)

    next unless record && parent

    record.update!(parent_id: parent.id)
  end
end

def import_resources(path)
  return unless File.exist?(Rails.root.join(path, 'resources.yaml'))

  YAML.load_file(Rails.root.join(path, 'resources.yaml'), symbolize_names: true).each do |resource|
    namespace = resource.fetch(:namespace, "default")
    next if Junction::Resource.find_by(name: resource[:name], namespace: namespace)

    Rails.logger.info "Creating resource #{resource[:title]}"
    resource[:system] = find_reference(Junction::System, resource[:system], namespace) if resource[:system].present?
    resource[:owner] = find_reference(Junction::Group, resource[:owner], namespace) if resource[:owner].present?

    Junction::Resource.create(resource.except(:dependencies))
  end
end

def import_systems(path)
  return unless File.exist?(Rails.root.join(path, 'systems.yaml'))

  YAML.load_file(Rails.root.join(path, 'systems.yaml'), symbolize_names: true).each do |system|
    namespace = system.fetch(:namespace, "default")
    next if Junction::System.find_by(name: system[:name], namespace: namespace)

    Rails.logger.info "Creating system #{system[:title]}"
    system[:domain] = find_reference(Junction::Domain, system[:domain], namespace) if system[:domain].present?
    system[:owner] = find_reference(Junction::Group, system[:owner], namespace) if system[:owner].present?
    Junction::System.create(system)
  end
end

def import_users(path)
  return unless File.exist?(Rails.root.join(path, 'users.yaml'))

  YAML.load_file(Rails.root.join(path, 'users.yaml'), symbolize_names: true).each do |user|
    next if Junction::User.find_by(name: user[:name], namespace: user.fetch(:namespace, "default"))

    user[:title] = user[:name] if user[:title].blank?

    Rails.logger.info "Creating user #{user[:title]}"
    user[:password] = random_password
    entity = Junction::User.create(user)

    unless entity.persisted?
      puts "Failed to create user #{user[:title]}"
    end
  end
end

# Links dependencies between entities that have already been imported.
#
# Dependencies are declared as `type:name` (e.g. `component:junction`), where
# the name may be namespace qualified. Linking them in a pass of their own
# allows an entity to depend on any other, regardless of the order the entity
# types are imported in.
#
# @param path [String] Path to the seed data for the organization.
def link_dependencies(path)
  {
    'apis.yaml' => Junction::Api,
    'components.yaml' => Junction::Component,
    'resources.yaml' => Junction::Resource
  }.each do |file, model|
    next unless File.exist?(Rails.root.join(path, file))

    YAML.load_file(Rails.root.join(path, file), symbolize_names: true).each do |entity|
      next if entity[:dependencies].blank?

      namespace = entity.fetch(:namespace, "default")
      record = model.find_by(name: entity[:name], namespace: namespace)
      next unless record

      Rails.logger.info "Linking dependencies for #{entity[:title]}"
      targets = Hash.new { |dependencies, type| dependencies[type] = [] }

      entity[:dependencies].each do |dependency|
        type, name = dependency.split(':', 2)
        target = find_reference(Junction.const_get(type.capitalize), name.strip, namespace)
        targets["dependent_#{type}s"] << target if target
      end

      targets.each { |association, entities| record.public_send("#{association}=", entities) }
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
  link_dependencies(path)
end
