# frozen_string_literal: true

# A simple singleton module to hold our catalog options.
module CatalogOptions
  def self.options
    @options ||= begin
                   path = Rails.root.join("config", "catalog_options.yaml")
                   YAML.load_file(path).with_indifferent_access
                 end
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
