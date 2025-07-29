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
  YAML.load_file(Rails.root.join('db', 'seeds', 'programs.yaml'), symbolize_names: true).each do |program|
    next if Program.find_by(name: program[:name])

    Rails.logger.info "Creating program #{program[:name]}"
    Program.create(program)
  end

  YAML.load_file(Rails.root.join('db', 'seeds', 'projects.yaml'), symbolize_names: true).each do |project|
    next if Project.find_by(name: project[:name])

    Rails.logger.info "Creating project #{project[:name]}"
    project[:program] = Program.find_by(name: project[:program]) if project[:program].present?
    Project.create(project)
  end

  YAML.load_file(Rails.root.join('db', 'seeds', 'services.yaml'), symbolize_names: true).each do |service|
    next if Project.find_by(name: service[:name])

    Rails.logger.info "Creating service #{service[:name]}"
    service[:program] = Program.find_by(name: service[:program]) if service[:program].present?

    # service[:projects].map! do |project|
    #   Project.find_by(name: project)
    # end if service[:projects].present?
    service.fetch(:projects, []).map! do |project|
      Project.find_by(name: project)
    end

    service.fetch(:dependencies, []).map! do |dependency|
      Service.find_by(name: dependency)
    end

    pp(service)
    Service.create(service)
  end
end
