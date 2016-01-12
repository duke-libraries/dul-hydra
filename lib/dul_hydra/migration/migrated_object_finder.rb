module DulHydra::Migration
  class MigratedObjectFinder

    def self.find(fc3_uri_or_pid)
      fc3_pid = fc3_uri_or_pid.is_a?(RDF::URI) ?
                      fc3_uri_or_pid.to_s.gsub('info:fedora/', '') :
                      fc3_uri_or_pid
      search_results = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => fc3_pid)
      search_results.first
    end

  end
end
