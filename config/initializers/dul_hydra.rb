require 'dul_hydra'

DulHydra.configure do |config|
  config.collection_report_fields = [:pid, :identifier, :content_size, :content_checksum]
  config.contact_email = ENV['CONTACT_EMAIL']
  config.help_url = Rails.env.test? ? "http://www.loc.gov" : ENV['HELP_URL']
  config.csv_options = {
    encoding: "UTF-8",
    col_sep: "\t",
    headers: true,
    write_headers: true,
    header_converters: :symbol
  }
  config.create_menu_models = [ "Collection", "SimpleIngest" ]
  config.mets_folder_base_path = ENV['METS_FOLDER_BASE_PATH']
  config.simple_ingest_base_path = ENV['SIMPLE_INGEST_BASE_PATH']
end

Blacklight::Configuration.default_values[:http_method] = :post

if ENV["DDR_MODELS_TEMPDIR"]
  Ddr::Models.tempdir = ENV["DDR_MODELS_TEMPDIR"]
end

if Rails.env.production?
  Deprecation.default_deprecation_behavior = :silence
end
