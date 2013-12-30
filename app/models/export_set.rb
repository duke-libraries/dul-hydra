require 'zip/zip'

class ExportSet < ActiveRecord::Base

  include Hydra::AccessControlsEnforcement
  include Hydra::PolicyAwareAccessControlsEnforcement

  belongs_to :user
  has_attached_file :archive
  serialize :pids
  validates_presence_of :user, :pids
  validates :export_type, presence: true, if: :valid_type?

  module Types
    CONTENT = "content"
    DESCRIPTIVE_METADATA = "descriptive_metadata"

    def self.all
      constants(false)
    end

    def self.values
      all.collect { |c| const_get(c) }
    end
  end

  def self.valid_type?(t)
    Types.values.include? t
  end

  def valid_type?
    ExportSet.valid_type? export_type
  end

  def self.export_type_label(t)
    t.titleize rescue nil
  end

  def can_export?(obj)
    if export_content?
      obj.has_content? and current_ability.can?(:download, obj)
    else
      current_ability.can?(:read, obj)
    end
  end

  def bookmarked_objects_for_export
    @bookmarked_objects_for_export ||= get_objects_for_pids(self.user.bookmarked_document_ids)
  end

  def objects
    @objects ||= get_objects_for_pids(pids)
  end

  def export_content?
    export_type == Types::CONTENT
  end

  def export_descriptive_metadata?
    export_type == Types::DESCRIPTIVE_METADATA
  end

  def export_type_label
    ExportSet.export_type_label(export_type)
  end

  # Return boolean indicating that archive has been successfully created
  def create_archive
    send "add_#{export_type}_to_archive"
  end

  def add_descriptive_metadata_to_archive
    file_name = File.join(Dir.tmpdir, generate_archive_file_name('csv'))
    File.open(file_name, 'w', encoding: "UTF-8") do |file| # XXX use metadata_table.encoding?
      metadata_table = DulHydra::DescriptiveMetadataTable.new(objects)
      file.write(metadata_table.to_csv)
    end
    update_attributes({:archive => File.new(file_name, "rb")})
  ensure
    File.exists?(file_name) && File.unlink(file_name)
  end

  def add_content_to_archive
    Dir.mktmpdir do |tmpdir|
      zip_path = File.join(tmpdir, generate_archive_file_name('zip'))
      zip_size = Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zip_file|
        objects.each do |object|
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
        end # objects.each      
        zip_file.size
      end # Zip::ZipFile.open
      # update_attributes seems to be the way to get paperclip to work 
      # when not using file upload form submission to create the attachment
      (zip_size > 0) && update_attributes({:archive => File.new(zip_path, "rb")})
    end
  end


  def delete_archive
    archive = nil
    save
  end

  #
  # :current_user and :current_ability are defined here for integration with 
  # Hydra access controls enforcment.
  #
  def current_user
    user
  end

  # The duplicates the :current_ability method in ApplicationController
  def current_ability
    current_user ? current_user.ability : Ability.new(nil)
  end

  private 

  def generate_archive_file_name(ext)
    "export_set_#{Time.now.strftime('%Y%m%d%H%M%S')}.#{ext}"
  end

  def get_objects_for_pids(pid_array)
    return [] unless pid_array
    query = ActiveFedora::SolrService.construct_query_for_pids(pid_array)
    documents = ActiveFedora::SolrService.query(query, fq: gated_discovery_filters.join(" OR "))
    ActiveFedora::SolrService.reify_solr_results(documents, load_from_solr: true).select {|obj| can_export? obj}
  end

end
