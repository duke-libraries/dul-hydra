require "tempfile"
require "fileutils"

class DuracloudSerialization

  EVENT = Ddr::Models::Base::SAVE_NOTIFICATION
  OBJECT_DESC  = "object-desc.rdf"
  DATETIME_FORMAT = "%Y%m%d_%H%M%S"

  class_attribute :base_path

  def self.enable!(base_path = nil)
    self.base_path = base_path if base_path
    raise "`#{self}.base_path` is not set." unless self.base_path
    ActiveSupport::Notifications.subscribe(EVENT, self)
  end

  def self.disable!
    ActiveSupport::Notifications.unsubscribe(self)
  end

  # Receives notifications
  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    object_id = event.payload[:id]
    Resque.enqueue(DuracloudSerializationJob, object_id)
  end

  attr_reader :object, :zip_base, :target_dir

  def initialize(object)
    @object = object
    @zip_base = object.modified_date.strftime(DATETIME_FORMAT)
    @target_dir = File.join(base_path, object.id)
  end

  def call
    in_tmpdir do
      FileUtils.mkdir_p(zip_base)
      FileUtils.cd(zip_base) { serialize }
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

  def serialize
    write_object_description
    write_files
  end

  def in_tmpdir
    Dir.mktmpdir do |tmpdir|
      FileUtils.cd(tmpdir) do
        yield
      end
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
      DuracloudFileSerialization.call(file, File.absolute_path(id.to_s))
    end
  end

end
