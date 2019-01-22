# frozen_string_literal: true

require 'plist'

module Loco
  # Base class for writing and parsing ios string files
  class CocoaAdapter < BaseAdapter
    # ====================================
    # Methods to override

    # All the extensions allowed for that adapter
    #
    # Must be written with the '.' like '.xml'
    #
    # @return [Array] an array of all the allowed extensions
    def allowed_extensions
      ['.strings', '.stringsdict']
    end

    def parse(string, extension)
      if extension == '.strings'
        [read_strings(string), {}]
      elsif extension == '.stringsdict'
        [{}, read_stringsdict(string)]
      else
        raise "Unexpected string extension #{extension}"
      end
    end

    def directory(mapped_locale, _is_default)
      "#{mapped_locale}.lproj"
    end

    def default_file_name
      'Localizable'
    end

    def write_locale(directory,
                     file,
                     strings,
                     plurals,
                     locale,
                     date)

      unless strings&.empty?
        write_strings(path: File.join(directory, "#{file}.strings"),
                      strings: strings,
                      file: file,
                      locale: locale,
                      date: date)
      end

      # rubocop:disable Style/GuardClause
      unless plurals&.empty?
        write_plurals(path: File.join(directory, "#{file}.stringsdict"),
                      plurals: plurals,
                      file: file,
                      locale: locale,
                      date: date)
      end
      # rubocop:enable Style/GuardClause
    end

    # ====================================
    # Reading

    def read_stringsdict(string)
      xml = Plist.parse_xml string

      plurals = {}

      xml.each do |key, value|
        format_key = value['NSStringLocalizedFormatKey']

        unless format_key =~ /^%#@[\w]*@$/
          puts "Unsupported format key '#{format_key}'"
          next
        end

        format_key = format_key[3..-2]

        translations = value[format_key]
        if translations.nil?
          puts 'Empty translation dict'
          next
        end

        if translations.delete('NSStringFormatSpecTypeKey') != 'NSStringPluralRuleType'
          puts 'Unsupported plural rule'
          next
        end

        translations.delete('NSStringFormatValueTypeKey')

        plurals[key] = translations
      end

      plurals
    end

    def read_strings(string)
      matches = string.scan(/^"(.*)" = "(.*)";$/)

      strings = {}
      matches.each do |array|
        strings[array[0]] = array[1] if array.count == 2
      end

      # if @clean_plurals

      #   # Removing plurals
      #   #
      #   # A plural key is identified with a '-plural' at the end.
      #   #
      #   # These keys are duplicated from stringsdict file.
      #   plural_keys = strings.keys.select { |key| key[-7..-1] == '-plural' }

      #   plural_keys.each do |key|
      #     root_key = key[0..-8]
      #     unless strings[root_key].nil?
      #       strings.delete(root_key)
      #       strings.delete(key)
      #     end
      #   end

      # end

      strings
    end

    # ====================================
    # Writing Strings

    # Writes a string file to the provided path
    def write_strings(path:,
                      strings:,
                      file:,
                      locale:,
                      date:)

      content = to_strings strings
      header = header(File.dirname(__FILE__) + '/ios_header.strings',
                      file,
                      locale,
                      date)

      merged = header + "\n" + content
      File.write path, merged
    end

    def to_strings(strings)
      array = strings.map do |key, value|
        "\"#{key}\" = \"#{value}\";"
      end

      array.sort!
      array.join("\n\n")
    end

    # ====================================
    # Writing Plurals

    def write_plurals(path:,
                      plurals:,
                      file:,
                      locale:,
                      date:)

      content = to_stringsdict plurals
      header = header(File.dirname(__FILE__) + '/ios_header.stringsdict',
                      file,
                      locale,
                      date)

      lines = content.split("\n")
      lines.insert 2, header
      merged = lines.join "\n"
      File.write path, merged
    end

    def to_stringsdict(plurals)
      all = {}
      plurals.each do |key, value|
        translations = value.clone
        translations['NSStringFormatSpecTypeKey'] = 'NSStringPluralRuleType'
        translations['NSStringFormatValueTypeKey'] = 'd'

        all[key] = {
          'NSStringLocalizedFormatKey': '%#@items@',
          'items': translations
        }
      end

      all.to_plist
    end
  end
end
