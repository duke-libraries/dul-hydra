require 'zip/zip'

class ExportSet < ActiveRecord::Base

  belongs_to :user
  has_attached_file :archive
  attr_accessible :archive, :pids, :title
  serialize :pids

  MANIFEST_FILE_NAME = "README.txt"
  MANIFEST_HEADER = ['FILE', 'TITLE', 'ITEM', 'COLLECTION']

  def create_archive
    unless pids
      logger.warn "Export set has no pids -- will not create empty archive."
      return false
    end
    Dir.mktmpdir do |tmpdir|
      # manifest
      tmpmf = File.join(tmpdir, MANIFEST_FILE_NAME)
      # create the zip archive
      zip_name = "export_set_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
      zip_path = File.join(tmpdir, zip_name)
      Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zip_file|
        CSV.open(tmpmf, 'wb') do |manifest|
          manifest << MANIFEST_HEADER
          pids.each do |pid|
            # get Fedora object
            begin
              object = ActiveFedora::Base.find(pid, :cast => true) 
              # skip if object is not content-bearing - XXX log warning?
              next unless object.respond_to?(:has_content?) && object.has_content?
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
              # add entry to manifest
              item_title = object.item.title_display rescue ""
              collection_title = object.collection.title_display rescue ""
              manifest << [file_name,
                           object.title_display,
                           item_title,
                           collection_title
                          ]
            rescue ActiveFedora::ObjectNotFoundError => e
              logger.error e
              next
            end
          end # document_list
        end # manifest
        # XXX what if zip file is empty?
        # write manifest        
        zip_file.add(MANIFEST_FILE_NAME, tmpmf)
      end # zip_file
      # update_attributes seems to be the way to get paperclip to work 
      # when not using file upload form submission to create the attachment
      update_attributes({:archive => File.new(zip_path, "rb")})
    end # tmpdir is removed
    # TODO Return a success/fail flag
  end

end
