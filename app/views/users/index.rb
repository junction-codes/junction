# frozen_string_literal: true

# Index view for users.
class Views::Users::Index < Views::Base
  attr_reader :query, :users

  # Initializes the view.
  #
  # @param users [ActiveRecord::Relation] Collection of users to display.
  # @param query [Ransack::Search] Ransack query object for filtering and
  #   sorting.
  def initialize(users:, query:)
    @users = users
    @query = query
  end

  def view_template
    render Layouts::Application do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") { "Users" }
          Link(variant: :primary, href: new_user_path) do
            "New User"
          end
        end

        Components::UserFilters(query:)

        div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
          render Components::Table do |table|
            table_header(table)
            table_body(table)
          end
        end
      end
    end
  end

  private

  def table_header(table)
    table.header do |header|
      header.row do |row|
        sort_url = ->(field, direction) { users_path(q: { s: "#{field} #{direction}" }) }

        row.sortable_head(query:, field: "display_name", sort_url:) { "User" }
        row.sortable_head(query:, field: "email_address", sort_url:) { "Email" }
      end
    end
  end

  def table_body(table)
    table.body do |body|
      @users.each do |user|
        body.row do |row|
          row.cell do
            div(class: "flex items-center space-x-4") do
              # Logo or placeholder image.
              if user.image_url.present?
                img(src: user.image_url, alt: "#{user.display_name} logo", class: "h-12 w-12 rounded-md object-cover flex-shrink-0")
              else
                div(class: "h-12 w-12 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                  icon("user-round", class: "h-6 w-6 text-gray-500")
                end
              end

              div do
                div(class: "text-sm font-medium text-gray-900 dark:text-white") do
                  a(href: user_path(user)) { user.display_name }
                end

                div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { user.pronouns }
              end
            end
          end

          row.cell do
            Link(href: "mailto:#{user.email_address}", class: "ps-0") { user.email_address }
          end
        end
      end
    end
  end
end
