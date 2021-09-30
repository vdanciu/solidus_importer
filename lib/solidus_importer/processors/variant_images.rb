# frozen_string_literal: true

module SolidusImporter
  module Processors
    class VariantImages < Base
      @saved_images = {}

      class << self
        attr_accessor :saved_images  # provide class methods for reading/writing
      end

      def call(context)
        @data = context.fetch(:data)
        return unless variant_image?
        variant = context.fetch(:variant)
        process_images(variant)
      end

      private

      def prepare_image
        attachment = @data['Variant Image']
        
        if (self.class.saved_images.key?(attachment))
          return self.class.saved_images[attachment]
        end

        if attachment.match?(/^http/)
          io = URI.parse(attachment).open
          io.define_singleton_method(:to_path) do
            File.basename(URI.parse(attachment).path)
          end
        elsif File.exist?(attachment)
          io = File.open(attachment)
        else
          raise URI::InvalidURIError, "bad URI #{attachment}"
        end

        image = Spree::Image.new
        image.tap { |i| i.attachment = io }
        self.class.saved_images[attachment] = image
        image
      end

      def process_images(variant)
        variant.images << prepare_image
      end

      def variant_image?
        @variant_image ||= @data['Variant Image'].present?
      end
    end
  end
end
