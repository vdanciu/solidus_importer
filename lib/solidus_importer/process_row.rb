# frozen_string_literal: true

module SolidusImporter
  ##
  # This class process a single row of an import running the configured
  # processor in chain.
  class ProcessRow
    def initialize(importer, row)
      @importer = importer
      @row = row
      validate!
    end

    def process(initial_context)
      context = initial_context.dup.merge!(row_id: @row.id, importer: @importer, data: @row.data)
      @importer.processors.each do |processor|
        processor.call(context)
      rescue StandardError => e
        context.merge!(success: false, messages: "#{e.message} in #{e.backtrace.join("\n")}") # rubocop:disable Performance/RedundantMerge
        SolidusImporter::Config.row_exception_handler.call(e, context)
        break
      end

      @importer.handle_row_import(context)

      @row.update!(
        state: context[:success] ? :completed : :failed,
        messages: context[:messages]
      )
      check_import_finished(context)
      context
    end

    private

    def check_import_finished(_context)
      return unless @row.import.finished?

      @row.import.update!(state: (@row.import.rows.failed.any? ? :failed : :completed))
    end

    def validate!
      raise SolidusImporter::Exception, 'No importer defined' if !@importer
      raise SolidusImporter::Exception, 'Invalid row type' if !@row || !@row.is_a?(SolidusImporter::Row)
    end
  end
end
