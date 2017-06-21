require 'pdk'
require 'pdk/cli/exec'
require 'pdk/util'
require 'pdk/util/bundler'
require 'pdk/validators/base_validator'
require 'pdk/validators/ruby_validator'

module PDK
  module Validate
    class Rubocop < BaseValidator
      def self.name
        'rubocop'
      end

      def self.cmd
        File.join(PDK::Util.module_root, 'bin', 'rubocop')
      end

      def self.spinner_text
        _('Checking Ruby code style')
      end

      def self.parse_options(_options, targets)
        cmd_options = ['--format', 'json']

        cmd_options.concat(targets)
      end

      def self.invoke(report, options = {})
        PDK::Util::Bundler.ensure_bundle!
        PDK::Util::Bundler.ensure_binstubs!('rubocop')

        super
      end

      def self.parse_output(report, json_data)
        return unless json_data.key?('files')

        json_data['files'].each do |file_info|
          next unless file_info.key?('offenses')
          result = {
            file: file_info['path'],
            source: 'rubocop',
          }

          if file_info['offenses'].empty?
            report.add_event(result.merge(state: :passed, severity: :ok))
          else
            file_info['offenses'].each do |offense|
              report.add_event(
                result.merge(
                  line:     offense['location']['line'],
                  column:   offense['location']['column'],
                  message:  offense['message'],
                  severity: offense['severity'],
                  test:     offense['cop_name'],
                  state:    :failure,
                ),
              )
            end
          end
        end
      end
    end
  end
end