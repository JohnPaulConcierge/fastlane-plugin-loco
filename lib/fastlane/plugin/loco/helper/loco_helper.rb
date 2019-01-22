# frozen_string_literal: true

require 'fastlane_core/ui/ui'

# Fastlane module
module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?('UI')

  module Helper
    # Base helper for Loco plugin
    class LocoHelper
      # class methods that you define here become available in your action
      # as `Helper::LocoHelper.your_method`
      #
      def self.show_message; end

    end
  end
end
