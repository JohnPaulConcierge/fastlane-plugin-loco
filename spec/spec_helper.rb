# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# Disabling all remote calls
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/loco' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
