# frozen_string_literal: true

module Components
  class StatCard < Base
    def initialize(title:, value:, icon:, status: :default)
      @title = title
      @value = value
      @icon = icon
      @status = status
    end

    def view_template
      render Card.new(class: "bg-white dark:bg-gray-800 overflow-hidden") do |card|
        div(class: "flex items-start justify-between") do
          card.header do |header|
            header.title(class: "text-sm font-medium text-gray-500 dark:text-gray-400") { @title }
          end

          div(class: "m-5 flex-shrink-0 p-3 rounded-full #{icon_bg_color}") do
            icon(@icon, class: "w-6 h-6 #{icon_color}")
          end
        end

        card.content(class: "mt-1 text-3xl font-semibold #{value_color}") do
          @value
        end
      end
    end

    private

    def value_color
      case @status
      when :critical
        "text-orange-600 dark:text-orange-400"
      when :danger
        "text-red-600 dark:text-red-400"
      when :healthy
        "text-green-600 dark:text-green-400"
      when :warning
        "text-yellow-600 dark:text-yellow-400"
      else
        "text-gray-900 dark:text-white"
      end
    end

    def icon_bg_color
      case @status
      when :critical
        "bg-orange-100 dark:bg-orange-900/50"
      when :danger
        "bg-red-100 dark:bg-red-900/50"
      when :healthy
        "bg-green-100 dark:bg-green-900/50"
      when :warning
        "bg-yellow-100 dark:bg-yellow-900/50"
      else
        "bg-gray-100 dark:bg-gray-700"
      end
    end

    def icon_color
      case @status
      when :critical
        "text-orange-600 dark:text-orange-400"
      when :danger
        "text-red-600 dark:text-red-400"
      when :healthy
        "text-green-600 dark:text-green-400"
      when :warning
        "text-yellow-600 dark:text-yellow-400"
      else
        "text-gray-600 dark:text-gray-400"
      end
    end
  end
end
