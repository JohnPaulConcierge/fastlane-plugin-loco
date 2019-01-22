# frozen_string_literal: true

require 'nokogiri'

module Loco
  # Class for writing and parsing android xmls
  class AndroidAdapter < BaseAdapter
    # ====================================
    # Inherited methods

    def allowed_extensions
      ['.xml']
    end

    def parse(string, _extension)
      strings = {}
      plurals = {}

      xml = Nokogiri::XML(string)
      xml.xpath('//string').each do |node|
        strings[node.attribute('name').to_s] = node.content
      end

      xml.xpath('//plurals').each do |node|
        plural = {}

        node.xpath('item').each do |item|
          plural[item.attribute('quantity').to_s] = item.content
        end

        plurals[node.attribute('name').to_s] = plural
      end

      [strings, plurals]
    end

    def directory(mapped_locale, is_default)
      is_default ? 'values' : "values-#{mapped_locale}"
    end

    def default_file_name
      'strings'
    end

    def write_locale(directory,
                     file,
                     strings,
                     plurals,
                     locale,
                     date)

      xml = to_xml strings, plurals
      path = File.join(directory, file + '.xml')
      header = header File.dirname(__FILE__) + '/android_header.xml', file, locale, date

      merged = merge_xml_and_header xml, header
      File.write path, merged
    end

    # ====================================
    # Custom methods, no need to call directly

    # Returns an xml string
    def to_xml(strings, plurals)
      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.resources do
          strings.each do |name, string|
            xml.string string, name: name
          end

          plurals.each do |name, items|
            xml.plurals(name: name) do
              items.each do |quantity, string|
                xml.item string, quantity: quantity
              end
            end
          end
        end
      end

      builder.to_xml
    end

    # Inserts the header with the xml content
    def merge_xml_and_header(xml, header)
      return header if xml.empty?
      return xml if header.empty?

      line_sep = "\n"
      xml_lines = xml.split(line_sep)
      header_lines = header.split(line_sep)
      # inserting header after first line
      xml_lines.insert 1, header_lines

      xml_lines.flatten!.join(line_sep)
    end
  end
end
