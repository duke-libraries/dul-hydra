module ExportFiles
  class Finder

    attr_reader :identifiers, :ability

    def initialize(identifiers, ability: nil)
      @identifiers = identifiers
      @ability = ability
    end

    def query
      @query ||= Ddr::Index::Query.build(identifiers) { |ids| where(identifier_all: ids) }
    end

    def permitted?(doc)
      return true unless ability
      ability.can?(:download, doc)
    end

    def permitted
      @permitted ||= query.docs.select { |doc| permitted?(doc) }
    end

    def found
      @found ||= identifiers & permitted_identifiers
    end

    def not_found
      @not_found ||= identifiers - found
    end

    def results
      @results ||= permitted.map do |doc|
        case doc.active_fedora_model
        when "Item"
          find_children(doc)
        when "Collection"
          find_components(doc)
        else
          doc
        end
      end.flatten
    end

    def content_ids
      @content_ids ||= results.map(&:id)
    end
    alias_method :repo_ids, :content_ids

    def num_files
      results.length
    end

    def total_content_size
      results.map(&:content_size).map(&:to_i).reduce(:+)
    end

    def objects
      Enumerator.new do |e|
        repo_ids.each do |id|
          e << ActiveFedora::Base.find(id)
        end
      end
    end

    private

    def permitted_identifiers
      # This ugliness is due to the behavior of Ddr::Models::SolrDocument#method_missing.
      permitted.map { |doc| doc[Ddr::Index::Fields::IDENTIFIER_ALL] }.flatten
    end

    def children_query(item)
      Ddr::Index::Query.new { is_part_of(item.id) }
    end

    def find_children(item)
      children_query(item).docs.to_a
    end

    def components_query(collection)
      Ddr::Index::Query.new do
        model "Component"
        is_governed_by collection.id
      end
    end

    def find_components(collection)
      components_query(collection).docs.to_a
    end

  end
end
