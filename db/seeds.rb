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

    Rails.logger.info "Creating #{program[:name]}"
    Program.create(program)
  end
end
