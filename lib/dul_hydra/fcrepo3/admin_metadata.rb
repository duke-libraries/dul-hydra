require "rdf/ntriples"

module DulHydra::Fcrepo3
  class AdminMetadata

    attr_reader :source

    def self.convert!(source)
      new(source).convert!
    end

    # @param f3_datastream [Rubydora::Datastream] the Fcrepo3 source datastream
    def initialize(f3_datastream)
      @source = f3_datastream
    end

    def convert!
      source.content = f4_graph.dump(:ntriples)
    end

    def subject
      RDF::URI("info:fedora/#{source.pid}")
    end

    def f3_graph
      RDF::Graph.new.from_ntriples(source.content)
    end

    def f4_graph
      graph = f3_graph
      insert_f4_role_statement(graph)
      delete_f3_role_statements(graph)
      graph
    end

    def delete_f3_role_statements(graph)
      statements = graph.query(f3_has_role_query).map { |solution| [solution[:role], nil, nil] }
      statements << [nil, Ddr::Vocab::Roles.hasRole, nil]
      graph.delete *statements
    end

    def insert_f4_role_statement(graph)
      roles = []
      graph.query(f3_role_query) do |solution|
        roles << Ddr::Auth::Roles::Role.new(solution.to_hash)
      end
      role_set = Ddr::Auth::Roles::RoleSet.new(roles: roles)
      graph.insert [subject, Ddr::Vocab::Roles.roleSet, role_set.to_json]
    end

    def f3_has_role_query
      RDF::Query.new({ has_role: { Ddr::Vocab::Roles.hasRole => :role } })
    end

    def f3_role_query
      RDF::Query.new(
        { role: {
            RDF.type => Ddr::Vocab::Roles.Role,
            Ddr::Vocab::Roles.type => :role_type,
            Ddr::Vocab::Roles.agent => :agent,
            Ddr::Vocab::Roles.scope => :scope,
          }
        }
      )
    end

  end
end
