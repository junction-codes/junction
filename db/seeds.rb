# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  YAML.load_file(Rails.root.join('db', 'seeds', 'domains.yaml'), symbolize_names: true).each do |domain|
    next if Domain.find_by(name: domain[:name])

    Rails.logger.info "Creating domain #{domain[:name]}"
    Domain.create(domain)
  end

  YAML.load_file(Rails.root.join('db', 'seeds', 'systems.yaml'), symbolize_names: true).each do |system|
    next if System.find_by(name: system[:name])

    Rails.logger.info "Creating system #{system[:name]}"
    system[:domain] = Domain.find_by(name: system[:domain]) if system[:domain].present?
    System.create(system)
  end

  YAML.load_file(Rails.root.join('db', 'seeds', 'components.yaml'), symbolize_names: true).each do |component|
    next if System.find_by(name: component[:name])

    Rails.logger.info "Creating component #{component[:name]}"
    component[:domain] = Domain.find_by(name: component[:domain]) if component[:domain].present?

    # component[:systems].map! do |system|
    #   System.find_by(name: system)
    # end if component[:systems].present?
    component.fetch(:systems, []).map! do |system|
      System.find_by(name: system)
    end

    component.fetch(:dependencies, []).map! do |dependency|
      Component.find_by(name: dependency)
    end

    pp(component)
    Component.create(component)
  end
end
