# frozen_string_literal: true

require 'yaml'
require_relative 'project'

module Loco
  PLATFORM_IOS = 'ios'
  PLATFORM_ANDROID = 'android'

  # Base class for a Table, i-e one or several files containing translations
  #
  # This holds the projects to pull from as well as the translations.
  class Table
    def initialize(platform:,
                   directory:,
                   table: '',
                   locales: ['en'],
                   projects:,
                   mapping: nil)
      @directory = directory
      @table = table
      @locales = locales
      @mapping = mapping
      @projects = projects.map do |i|
        Project.new(i.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; })
      end

      if platform == PLATFORM_ANDROID
        @adapter = AndroidAdapter.new
      elsif platform == PLATFORM_IOS
        @adapter = CocoaAdapter.new
      else
        raise "Unsupported platform '#{platform}'"
      end

      @strings = {}
      @plurals = {}
    end

    attr_reader :directory
    attr_reader :table
    attr_reader :locales
    attr_reader :mapping
    attr_reader :projects
    attr_reader :strings
    attr_reader :plurals

    # Loads the entire strings and plurals for the provided locale
    def load_locale!(locale)
      @projects.each do |project|
        @adapter.allowed_extensions.each do |extension|
          result = project.export locale, extension

          if result.nil?
            raise "Could not load project #{project} with extension #{extension} and locale #{locale}"
          end

          strings, plurals = @adapter.parse result, extension

          strings = project.filter strings
          plurals = project.filter plurals

          @strings[locale] = (@strings[locale] || {}).merge(strings)
          @plurals[locale] = (@plurals[locale] || {}).merge(plurals)
        end
      end
    end

    def load!
      @locales.each do |l|
        load_locale!(l)
      end
    end

    def locale_directory(locale, is_default)
      mapped_locale = @mapping && @mapping[locale] || locale

      File.join(@directory,
                @adapter.directory(mapped_locale, is_default))
    end

    # Writes the content of a table to the appropriate location
    #
    # This method calls the adapter write locale function
    def write!
      Dir.mkdir @directory unless File.directory? @directory

      @locales.each_with_index do |locale, index|
        strings = @strings[locale]
        plurals = @plurals[locale]

        l_directory = locale_directory locale, index.zero?

        file = @table.to_s.empty? ? @adapter.default_file_name : @table

        date = DateTime.now

        Dir.mkdir l_directory unless File.directory? l_directory

        @adapter.write_locale(l_directory,
                              file,
                              strings,
                              plurals,
                              locale,
                              date)
      end
    end

    # Static method used to read a conf file and extract the Table array
    def self.read_conf(path)
      array = YAML.safe_load(File.read(path))

      defaults = array.slice!(0)
      if array.empty?
        [Table.new(defaults.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; })]
      else
        array.map do |i|
          Table.new(defaults.merge(i).each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v; })
        end
      end
    end

    # Pretty to_s
    def to_s
      "#{@table.empty? ? @adapter.default_file_name : @table}: #{locales.join(', ')}"
    end
  end
end
