require 'dul_hydra'

DulHydra.configure do |config|
  config.contact_email = ENV['CONTACT_EMAIL']
  config.help_url = Rails.env.test? ? "http://www.loc.gov" : ENV['HELP_URL']
  config.csv_options = {
    encoding: "UTF-8",
    col_sep: "\t",
    headers: true,
    write_headers: true,
    header_converters: :symbol
  }
  config.metadata_file_creators_group = ENV['METADATA_FILE_CREATORS_GROUP']
  config.create_menu_models = [ "Collection", "MetadataFile", "NestedFolderIngest", "StandardIngest" ]
  config.preview_banner_msg = ENV['PREVIEW_BANNER_MSG']
  config.collection_report_fields = [:pid, :local_id, :content_size]
end

Blacklight::Configuration.default_values[:http_method] = :post

if ENV["DDR_MODELS_TEMPDIR"]
  Ddr::Models.tempdir = ENV["DDR_MODELS_TEMPDIR"]
end
