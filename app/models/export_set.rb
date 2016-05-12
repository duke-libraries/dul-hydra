require 'zip'

class ExportSet < ActiveRecord::Base

  belongs_to :user
  has_attached_file :archive
  do_not_validate_attachment_file_type :archive
  serialize :pids

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

  CSV_COL_SEP_OPTIONS = {
    "tab" => "\t",
    "comma" => ",",
    "double pipe" => "||"
    }

  validates_presence_of :user, :pids
  validates :export_type, inclusion: { in: Types.values }
  validates :csv_col_sep, inclusion: { in: CSV_COL_SEP_OPTIONS }, if: :export_descriptive_metadata?

  def has_archive?
    !archive_file_name.nil?
  end

  def delete_archive
    has_archive? && update!(archive: nil)
  end

  def self.valid_type?(t)
    Types.values.include? t
  end

  def valid_type?
    ExportSet.valid_type? export_type
  end

  def self.export_type_label(t)
    t.titleize if t.respond_to?(:titleize)
  end

  def can_export?(obj)
    if export_content?
      obj.has_content? and current_ability.can?(:download, obj)
    else
      current_ability.can?(:read, obj)
    end
  end

  def bookmarked_objects_for_export
    @bookmarked_objects_for_export ||= get_objects_for_pids(user.bookmarks.pluck(:document_id))
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

  def create_archive
    has_archive? ? false : export
  end

  def export
    send "export_#{export_type}"
  end

  def update_archive(file_name)
    update!(archive: File.new(file_name, "rb"))
  end

  def csv_options
    if csv_col_sep
      {col_sep: CSV_COL_SEP_OPTIONS.fetch(csv_col_sep)}
    else
      {}
    end
  end

  def export_descriptive_metadata
    file_name = File.join(Dir.tmpdir, generate_archive_file_name('csv'))
    File.open(file_name, 'w', encoding: "UTF-8") do |file| # XXX use metadata_table.encoding?
      logger.debug "Created temporary file #{file_name} for exporting metadata."
      metadata_table = DulHydra::DescriptiveMetadataTable.new(objects)
      file.write(metadata_table.to_csv(csv_options))
      logger.debug "Export set descriptive metadata written to file."
    end
    unless File.size?(file_name)
      raise Ddr::Models::Error, "Unable to archive empty or non-existent file."
    end
    update_archive(file_name)
  ensure
    File.exists?(file_name) && File.unlink(file_name)
    logger.debug "Temporary file #{file_name} deleted."
  end

  def export_content
    Dir.mktmpdir do |tmpdir|
      logger.debug "Created temp directory #{tmpdir} for export set content archive."
      zip_path = File.join(tmpdir, generate_archive_file_name('zip'))
      Zip::File.open(zip_path, Zip::File::CREATE) do |zip_file|
        logger.debug "Created zip file #{zip_path} for export set content archive."
        objects.each do |object|
          # use guaranteed unique file name based on PID and dsID
          temp_file_path = File.join(tmpdir, object.content.default_file_name)
          # write content to file
          File.open(temp_file_path, 'wb', :encoding => 'ascii-8bit') do |f|
            f.write object.content.content
            logger.debug "Wrote object #{object.id} content to file."
          end
          # Use original source file name, if available, or the generated file name.
          # Note that we keep the path of the source file in order to reduce the likelihood
          # of name conflicts, and since it is easy to flatten zip contents on extraction.
          # However, we don't want the path of the generated temp file, just the basename.
          file_name = object.original_filename || File.basename(temp_file_path)
          # discard leading slash, if present
          file_name = file_name[1..-1] if file_name.start_with? '/'
          # add file to archive
          zip_file.add(file_name, temp_file_path)
          logger.debug "Added file to zip archive."
        end # objects.each
      end # Zip::ZipFile.open
      unless File.size?(zip_path)
        raise Ddr::Models::Error, "Unable to archive empty or non-existent file."
      end
      # update seems to be the way to get paperclip to work
      # when not using file upload form submission to create the attachment
      update_archive(zip_path)
    end
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

  def get_objects_for_pids(pids)
    if pids.nil?
      return []
    end
    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(pids)
    documents = ActiveFedora::SolrService.post_query(query, rows: pids.size)
    ActiveFedora::QueryResultBuilder.reify_solr_results(documents, load_from_solr: true).select {|obj| can_export? obj}
  end

end
