require 'zip/zip'

class ExportSet < ActiveRecord::Base

  belongs_to :user
  has_attached_file :archive
#  attr_accessible :archive, :pids, :title
  serialize :pids
  validates_presence_of :user, :pids

  # Creates the archive file for the export set
  def create_archive
    created = false
    empty = true
    Dir.mktmpdir do |tmpdir|
      # create manifest
      tmpmf = File.join(tmpdir, DulHydra.export_set_manifest_file_name)
      # create the zip archive
      zip_name = "export_set_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
      zip_path = File.join(tmpdir, zip_name)
      Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zip_file|
        CSV.open(tmpmf, 'wb') do |manifest|
          manifest << archive_manifest_header
          pids.each do |pid|
            # get Fedora object
            begin
              object = ActiveFedora::Base.find(pid, :cast => true) 
              # skip if object is not content-bearing or user lacks :read permission
              next unless object.has_content? and user.can?(:read, object)
              content_ds = object.datastreams[DulHydra::Datastreams::CONTENT]
              # use guaranteed unique file name based on PID and dsID 
              temp_file_path = File.join(tmpdir, content_ds.default_file_name)
              # write content to file
              File.open(temp_file_path, 'wb', :encoding => 'ascii-8bit') do |f|
                content_ds.write_content(f)
              end
              # Use original source file name, if available; otherwise the generated file name
              # Note that we keep the path of the source file in order to reduce likelihood
              # name conflicts, and since it is easy to flatten zip contents on extraction.
              # However, we don't want the path of the generated temp file, just the basename.
              file_name = object.source.first || File.basename(temp_file_path)
              # discard leading slash, if present
              file_name = file_name[1..-1] if file_name.start_with? '/'
              # add file to archive
              zip_file.add(file_name, temp_file_path)
              # add row to manifest
              manifest << archive_manifest_row(file_name, object)
            rescue ActiveFedora::ObjectNotFoundError => e
              logger.error e
              next
            end
          end # document_list
        end # manifest
        # check if the zip file is emtpy
        empty = (zip_file.size == 0)
        # write manifest        
        zip_file.add(DulHydra.export_set_manifest_file_name, tmpmf) unless empty
      end # zip_file
      # update_attributes seems to be the way to get paperclip to work 
      # when not using file upload form submission to create the attachment
      created = !empty && update_attributes({:archive => File.new(zip_path, "rb")})
    end # tmpdir is removed
    created
  end

  def delete_archive
    archive = nil
    save
  end

  private
  
  def archive_manifest_header
    ['FILE', 'TITLE', 'ITEM', 'COLLECTION', 'CHECKSUM', 'CHECKSUM_TYPE']
  end

  def archive_manifest_row(file_name, object)
    item_title = object.item.title_display rescue ""
    collection_title = object.collection.title_display rescue ""
    checksum = object.datastreams[DulHydra::Datastreams::CONTENT].checksum
    checksum_type = object.datastreams[DulHydra::Datastreams::CONTENT].checksumType
    [file_name, object.title_display, item_title, collection_title, checksum, checksum_type]
  end

end
