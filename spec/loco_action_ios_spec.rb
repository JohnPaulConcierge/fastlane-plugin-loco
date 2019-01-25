# frozen_string_literal: true

require 'fileutils'
require 'spec_helper'

describe Fastlane::Actions::LocoAction do
  describe '#run' do
    it 'loads and creates the right ios files' do
      %w[dummy1 dummy2].each do |key|
        %w[en fr].each do |locale|
          %w[strings stringsdict].each do |extension|
            stub_request(:get, "https://localise.biz/api/export/locale/#{locale}.#{extension}?key=#{key}")
              .to_return(body: File.read("spec/res/#{key}-#{locale}.#{extension}"))
          end
        end
      end

      output_path = 'test-results/spec'
      # FileUtils.remove_dir output_path, true

      Fastlane::Actions::LocoAction.run(conf_file_path: 'spec/res/LocoFile.ios.yml')

      # Checking that all files were created
      %w[en fr].each do |locale|
        %w[Localizable Other].each do |table|
          %w[strings stringsdict].each do |extension|
            path = File.join(output_path, "#{locale}.lproj/#{table}.#{extension}")
            expect(File).to exist(path)
          end
        end
      end
    end
  end
end
