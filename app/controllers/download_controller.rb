require 'zip/zip'

class DownloadController < ApplicationController

  include Blacklight::SolrHelper

  def bookmarked_content
    bookmark_ids = current_or_guest_user.bookmarks.collect { |b| b.document_id.to_s }
    response, document_list = get_solr_response_for_field_values(SolrDocument.unique_key, bookmark_ids)
    # hack to filter just Components
    # would be nice to filter DulHydra::Models::HasContent
    document_list.keep_if { |doc| doc.get(:active_fedora_model_s) == 'Component' }
    unless document_list.empty?
      tmpdir = Dir.mktmpdir
      # create the zip archive
      zip_name = "bookmarked_content_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
      zip_path = File.join(tmpdir, zip_name)
      Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zip_file|
        # iterate through docs
        document_list.each do |doc|
          # get Fedora object
          object = ActiveFedora::Base.find(doc.id, :cast => true)
          # write content to file
          file_name = object.content.default_file_name
          file_path = File.join(tmpdir, file_name)
          File.open(file_path, 'wb', :encoding => 'ascii-8bit') do |f|
            object.content.write_content(f)
          end
          zip_file.add(file_name, file_path)
        end # document_list
      end # zip_file
      # stream the zip file to client
      send_file zip_path, :filename => zip_name, :type => 'application/zip'
    end # unless
  end

end
