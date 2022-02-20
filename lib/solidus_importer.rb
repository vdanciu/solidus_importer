# frozen_string_literal: true

require 'util/logger'

require 'solidus_core'
require 'solidus_support'

require 'solidus_importer/version'
require 'solidus_importer/exception'
require 'solidus_importer/base_importer'
require 'solidus_importer/order_importer'

require 'solidus_importer/processors/base'
processors = File.join(__dir__, 'solidus_importer/processors/*.rb')
Dir[processors].sort.each { |file| require file }

require 'solidus_importer/configuration'
require 'solidus_importer/engine'
require 'solidus_importer/process_import'
require 'solidus_importer/process_row'

module SolidusImporter
  class << self
    def import!(import_path, type:)
      ProcessImport.import_from_file(import_path, type.to_sym)
    end

    def combined_first_and_last_name_in_address?
      SolidusSupport.combined_first_and_last_name_in_address? &&
        Spree::Address.column_names.include?('name')
    end
  end
end
