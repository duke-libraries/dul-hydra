module DulHydra
  module Migration
    class MigrationMetadata

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def migration_metadata
        admin_metadata.merge(desc_metadata).merge(relationships).merge(system_data)
      end

      def admin_metadata
        Ddr::Datastreams::AdministrativeMetadataDatastream.term_names.inject({}) do |memo, term|
          memo[term] = term_values(Ddr::Datastreams::ADMIN_METADATA, term)
          memo
        end.reject { |k,v| v.empty? }
      end

      def desc_metadata
        Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.inject({}) do |memo, term|
          memo[term] = term_values(Ddr::Datastreams::DESC_METADATA, term)
          memo
        end.reject { |k,v| v.empty? }
      end

      def relationships
        rels = {}
        rels[:admin_policy] = object.admin_policy.present? ? object.admin_policy.pid : nil
        rels[:attached_to] = object.respond_to?(:attached_to) && object.attached_to.present? ?
                                 object.attached_to.pid : nil
        rels[:external_target_for] = object.is_a?(Target) && object.collection.present? ? object.collection.pid : nil
        rels[:parent] = object.parent.present? ? object.parent.pid : nil
        rels.reject { |k,v| v.nil? }
      end

      def system_data
        sd = {}
        sd[:create_date] = object.create_date
        sd[:model] = object.class.name
        sd[:modified_date] = object.modified_date
        sd[:pid] = object.pid
        sd
      end

      private

      def term_values(dsid, term)
        if term == :format
          object.datastreams[dsid].format
        else
          object.datastreams[dsid].send(term)
        end
      end

    end
  end
end
