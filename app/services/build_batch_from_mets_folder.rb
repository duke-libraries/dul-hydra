class BuildBatchFromMETSFolder

  attr_reader :batch_user, :filesystem, :batch_name, :batch_description, :display_formats
  attr_accessor :batch, :collection

  def initialize(batch_user:, filesystem:, collection:, batch_name: 'METS Folder', batch_description: nil, display_formats: {})
    @batch_user = batch_user
    @filesystem = filesystem
    @collection = collection
    @batch_name = batch_name
    @batch_description = batch_description
    @display_formats = display_formats
  end

  def call
    @batch = create_batch
    traverse_filesystem
    batch.update_attributes(status: DulHydra::Batch::Models::Batch::STATUS_READY)
    batch
  end

  private

  def create_batch
    DulHydra::Batch::Models::Batch.create(user: batch_user, name: batch_name, description: batch_description)
  end

  def traverse_filesystem
    filesystem.tree.each_leaf do |leaf|
      mets_file = METSFile.new(Filesystem.path_to_node(leaf), collection)
      BuildBatchObjectFromMETSFile.new(batch: batch, mets_file: mets_file, display_formats: display_formats).call
    end
  end

end