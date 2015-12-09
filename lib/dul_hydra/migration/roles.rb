require "rdf/ntriples"

module DulHydra::Migration
  class Roles < Migrator

    # source: Rubydora::Datastream(dsid: "adminMetadata")
    # target: ActiveFedora::Base

    def migrate
      grant_roles_on_target!
      delete_roles_from_source!
    end

    def graph
      RDF::Graph.new.from_ntriples(source.content)
    end

    def grant_roles_on_target!
      roles = role_query.execute(graph).map(&:to_hash)
      if roles.present?
        target.roles.grant *roles
      end
    end

    def delete_roles_from_source!
      updated_graph = graph.delete [nil, Ddr::Vocab::Roles.hasRole, nil],
                                   [nil, RDF.type, Ddr::Vocab::Roles.Role],
                                   [nil, Ddr::Vocab::Roles.type, nil],
                                   [nil, Ddr::Vocab::Roles.agent, nil],
                                   [nil, Ddr::Vocab::Roles.scope, nil]
      source.content = updated_graph.dump(:ntriples)
    end

    def role_query
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
