require "tempfile"
require "fileutils"

class DuracloudSerialization

  EVENT = Ddr::Models::Base::SAVE_NOTIFICATION
  OBJECT_DESC  = "object-desc.rdf"
  DATETIME_FORMAT = "%Y%m%d_%H%M%S"

  class << self
    def enable!
      ActiveSupport::Notifications.subscribe(EVENT, self)
    end

    def disable!
      ActiveSupport::Notifications.unsubscribe(self)
    end

    # Receives notifications
    def call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      object_id = event.payload[:id]
      Resque.enqueue(DuracloudSerializationJob, object_id)
    end

    def serialize(object)
      new(object).serialize
    end
  end

  attr_reader :object, :zip_base, :target_dir

  def initialize(object)
    @object = object
    @zip_base = object.modified_date.strftime(DATETIME_FORMAT)
    @target_dir = File.join(DulHydra.duracloud_content_path, "METADATA", object.id)
  end

  def serialize
    in_tmpdir do
      FileUtils.mkdir_p(zip_base)
      FileUtils.cd(zip_base) { do_serialize }
      Bagit.call(zip_base)
      move(zip)
    end
  end

  private

  def zip
    `zip -r #{zip_base} #{zip_base}`
    "#{zip_base}.zip"
  end

  def move(file)
    FileUtils.mkdir_p(target_dir)
    FileUtils.mv(file, target_dir)
  end

  def do_serialize
    write_object_description
    write_files
  end

  def in_tmpdir
    Dir.mktmpdir do |tmpdir|
      FileUtils.cd(tmpdir) { yield }
    end
  end

  def write_object_description
    File.open(OBJECT_DESC, "wb") do |f|
      description = object.ldp_source.graph.dump(:rdfxml)
      f.write(description)
    end
  end

  def write_files
    object.attached_files_having_content.each do |id, file|
      dest = File.absolute_path(id.to_s)
      DuracloudFileSerialization.serialize(file, dest)
    end
  end

end
