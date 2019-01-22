# frozen_string_literal: true

module Loco
  # Base class for an adapter
  class BaseAdapter
    # ====================================
    # Methods to override

    # All the extensions allowed for that adapter
    #
    # This method is also used to determine what to load from the server
    #
    # Must be written with the '.' like '.xml'
    #
    # @return [Array] an array of all the allowed extensions
    def allowed_extensions
      []
    end

    # Parses the content of strings file
    #
    # @return [Array] an array of 2: strings, plurals
    def parse(_string, _extension)
      [{}, {}]
    end

    # Returns res directory for the mapped locale
    #
    # Base implementation does nothing
    #
    # @param [String] the mapped locale name
    # @param [true] whether the locale is the default one
    def directory(_mapped_locale, _is_default)
      ''
    end

    # Returns the default name
    def default_file_name
      ''
    end

    # Writes the locale to a directory
    def write_locale(directory, file, strings, plurals, locale, date); end

    # ====================================
    # Convenience methods to provide a single point of entry

    # Reads the content of a directory
    #
    # @param [String] directory a directory path with a wildcard like 'path/*' or 'path/**/*'
    #
    # @return [Array] an array of 2: strings, plurals
    def read(directory)
      strings = {}
      plurals = {}

      files = Dir[directory]
      files.each do |file|
        ext = ::File.extname(file)
        next unless allowed_extensions.include? ext

        parsed_strings, parsed_plurals = parse(::File.read(file), ext)

        strings = strings.merge(parsed_strings)
        plurals = plurals.merge(parsed_plurals)
      end

      [strings, plurals]
    end

    # Fills the header placeholders
    def header(path, file, locale, date)
      File.read(path)
          .gsub('<file>', file)
          .gsub('<locale>', locale)
          .gsub('<date>', date.to_s)
    end
  end
end
