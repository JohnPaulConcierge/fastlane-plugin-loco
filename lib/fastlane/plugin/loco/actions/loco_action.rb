# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/loco_helper'

module Fastlane
  module Actions
    # Base class for LocoAction
    class LocoAction < Action
      def self.run(params)
        tables = ::Loco::Table.read_conf(params[:conf_file_path])

        UI.message "Found #{tables.count} tables"

        tables.each do |table|
          UI.message 'Loading ' + table.to_s

          table.load!

          UI.message 'Found strings: ' + table.strings.map { |key, value| "#{key}: #{value.count}" }.join(', ')

          table.write!
        end
      end

      def self.description
        'Eases up retrieving translations from loco (localise.biz)'
      end

      def self.authors
        ['John Paul']
      end

      # def self.return_value
      #   # If your method provides a return value, you can describe here what it does
      # end

      def self.details
        # Optional:
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :conf_file_path,
                                       env_name: 'LOCO_CONF_FILE_PATH',
                                       description: 'The conf file path',
                                       optional: true,
                                       type: String,
                                       default_value: 'fastlane/LocoFile.yml')
        ]
      end

      def self.is_supported?(_platform) # rubocop:disable Style/PredicateName
        %i[ios mac android].include?(platform)
      end
    end
  end
end
