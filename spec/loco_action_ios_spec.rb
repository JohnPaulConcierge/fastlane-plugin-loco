# frozen_string_literal: true

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

      Fastlane::Actions::LocoAction.run(conf_file_path: 'spec/res/LocoFile.ios.yml')
    end
  end
end
