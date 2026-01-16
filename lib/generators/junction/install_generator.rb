# frozen_string_literal: true

module Junction
  module Generators
    # Generator to set up Junction in a host Rails application.
    class InstallGenerator < Rails::Generators::Base
      desc "Set up Junction in a host Rails application"

      def add_routes
        say "\n🛤️  Adding Junction routes...", :green
        route 'mount Junction::Engine => "/"'
      end

      def setup_database
        say "\n🚉 Setting up database...", :green

        config_path = Rails.root.join("config/database.yml")
        if config_path.exist?
          say "   ✓ database.yml exists"
        else
          say "   ⚠️  database.yml not found. Please configure your database manually.", :yellow
          say "      See config/database.example.yml for reference."
          return
        end

        rails_command("db:create", capture: true)
        say "   ✓ Database created"
      end

      def install_migrations
        say "🚃 Installing migrations...", :green
        rails_command("junction:install:migrations", capture: true)
        say "   ✓ Migrations installed"
      end

      def run_migrations
        say "\n🚅 Running migrations...", :green
        rails_command("db:migrate", capture: true)
        say "   ✓ Migrations complete"
      end

      def create_default_user
        say "\n🧑‍🔧 Creating default admin user...", :green

        if Junction::User.exists?(email_address: "admin@example.com")
          say "   ✓ Admin user already exists"
          return
        end

        Junction::User.create!(
          display_name: "Administrator",
          email_address: "admin@example.com",
          password: "passWord1!",
          password_confirmation: "passWord1!"
        )

        say "   ✓ Admin user created"
        say "      Email: admin@example.com"
        say "      Password: passWord1! (please change after first login!)", :yellow
      end

      def print_next_steps
        say "\n🚂 Junction installation complete!\n\n", :green
        say "Next steps:"
        say "  1. Start the server: bin/rails server"
        say "  2. Visit http://localhost:3000"
        say "  3. Log in with:"
        say "     Email: admin@example.com"
        say "     Password: passWord1!"
        say "\n"
      end
    end
  end
end
