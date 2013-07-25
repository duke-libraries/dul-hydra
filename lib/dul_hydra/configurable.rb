module DulHydra::Configurable
  extend ActiveSupport::Concern

  included do
    # Ordering of descriptive metadata fields on object page
    mattr_accessor :metadata_fields
    self.metadata_fields = [:title, :identifier, :source, :description, :date, :creator, :contributor, :publisher, :language, :subject, :type, :relation, :coverage, :rights]

    mattr_accessor :unwanted_models
#    self.unwanted_models = ["PreservationEvent", "Target", "AdminPolicy"]

    mattr_accessor :export_set_manifest_file_name
    self.export_set_manifest_file_name = "README.txt"

    mattr_accessor :collection_report_fields
    self.collection_report_fields = [:pid, :identifier]

  end

end
