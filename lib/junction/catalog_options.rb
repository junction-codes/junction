# frozen_string_literal: true

module Junction
  # A simple singleton module to load and provide access to catalog options.
  #
  # Options are loaded from `config/catalog_options.yaml` within this engine by
  # default, but can be overridden by placing a file of the same name in the
  # host application's `config` directory.
  #
  # @todo Revisit this implementation to use Rails configuration or another
  #   approach that better fits with Rails conventions.
  module CatalogOptions
    DEFAULT_PATH = File.join(__dir__, "..", "..", "config", "catalog_options.yaml").freeze

    def self.options
      @options ||= begin
                     override_path = Rails.root.join("config", "catalog_options.yaml")
                     path = override_path.exist? ? override_path : DEFAULT_PATH
                     YAML.load_file(path).with_indifferent_access
                   end
    end

    def self.apis
      options[:apis]
    end

    def self.environments
      options[:environments]
    end

    def self.group_types
      options[:group_types]
    end

    def self.kinds
      options[:kinds]
    end

    def self.lifecycles
      options[:lifecycles]
    end

    def self.platforms
      options[:platforms]
    end

    def self.resources
      options[:resources]
    end
  end
end
