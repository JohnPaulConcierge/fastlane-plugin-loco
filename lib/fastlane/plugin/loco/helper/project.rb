# frozen_string_literal: true

module Loco
  # Project class
  #
  # Holds the key to a loco project as well as what to include / exclude from it
  class Project
    def initialize(key:,
                   includes: [],
                   excludes: [])

      @key = key
      @includes = includes.map { |str| Regexp.new str }
      @excludes = excludes.map { |str| Regexp.new str }
    end

    attr_reader :key
    attr_reader :includes
    attr_reader :excludes

    # Exports the locale for the corresponding extension
    #
    # @param [String] the locale
    # @param [String] the extension, must include the `.`
    def export(locale, extension)
      uri = URI::HTTPS.build(scheme: 'https',
                             host: 'localise.biz',
                             path: "/api/export/locale/#{locale}#{extension}",
                             query: URI.encode_www_form('key': @key))
      res = Net::HTTP.get_response(uri)
      return res.body if res.code == '200'

      warn 'URL failed: ' + uri.to_s
      nil
    end

    def include?(key)
      @excludes.each do |e|
        return false if e.match(key)
      end

      @includes.each do |i|
        return true if i.match(key)
      end

      @includes.empty?
    end

    # Filters a dictionary by including / excluding keys using the respective
    # regexes
    def filter(resource)
      resource.select { |key, _value| include? key }
    end

    def to_s
      "Project(#{key}) "
    end
  end
end
