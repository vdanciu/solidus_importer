# frozen_string_literal: true

module SolidusImporter
  module Processors
    class Taxon < Base
      attr_accessor :product, :taxonomy

      def call(context)
        @data = context.fetch(:data)

        self.product = context.fetch(:product)

        process_taxons_type
        process_taxons_brand
        process_taxons_tags
      end

      private

      def options
        @options ||= {
          type_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Categories'),
          tags_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Tags'),
          brands_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Brands')
        }
      end

      def process_taxons_type
        parent = nil
        types.map do |type|
          taxon = prepare_taxon(type, options[:type_taxonomy], parent)
          add_taxon(taxon)
          parent ||= taxon
        end
      end

      def process_taxons_tags
        tags.map do |tag|
          add_taxon(prepare_taxon(tag, options[:tags_taxonomy]))
        end
      end

      def process_taxons_brand
        return unless brand

        add_taxon(prepare_taxon(brand, options[:brands_taxonomy]))
      end

      def add_taxon(taxon)
        product.taxons << taxon unless product.taxons.include?(taxon)
      end

      def prepare_taxon(name, taxonomy, parent = nil)
        parent_id = parent ? parent.id : taxonomy.root.id
        Spree::Taxon.find_or_create_by(
          name: name,
          taxonomy_id: taxonomy.id,
          parent_id: parent_id
        )
      end

      def tags
        return [] unless @data['Tags'].presence

        @data['Tags'].split(',').map(&:strip)
      end

      def types
        return [] unless @data['Type'].presence

        @data['Type'].split(',').map(&:strip)
      end

      def brand
        @data['Vendor'].presence
      end
    end
  end
end
