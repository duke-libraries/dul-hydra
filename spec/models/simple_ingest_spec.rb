require 'spec_helper'

RSpec.describe SimpleIngest, type: :model, simple_ingest: true do

  subject { SimpleIngest.new(simple_ingest_args) }

  let(:user) { FactoryGirl.create(:user) }

  describe "collection creating simple ingest" do
    let(:simple_ingest_args) { { 'admin_set' => 'dvs',
                                 'folder_path' => '/foo/bar',
                                 'batch_user' => user.user_key } }
    let(:batch_builder_args) { { user: user,
                                 filesystem: filesystem,
                                 content_modeler: ModelSimpleIngestContent,
                                 metadata_provider: SimpleIngestMetadata.new(File.join(data_path, METADATA_FILE), configuration[:metadata]),
                                 checksum_provider: SimpleIngestChecksum.new(File.join(folder_path, CHECKSUM_FILE)),
                                 batch_name: "Simple Ingest",
                                 batch_description: filesystem.root.name)
    }}
    before do
      expect(BuildBatchFromFolderIngest).to receive(:new)
    end
  end
end


# @admin_set = args['admin_set']
# @collection_id = args['collection_id']
# @config_file = args['config_file'] || DEFAULT_CONFIG_FILE.to_s
# @configuration = load_configuration
# @folder_path = args['folder_path']
# @user = User.find_by_user_key(args['batch_user'])
# @results = Results.new

def initialize(user:, filesystem:, content_modeler:, metadata_provider:, checksum_provider:, admin_set: nil,
               collection_repo_id: nil, batch_name: nil, batch_description:nil)
  @user = user
  @filesystem = filesystem
  @content_modeler = content_modeler
  @metadata_provider = metadata_provider
  @checksum_provider = checksum_provider
  @admin_set = admin_set
  @collection_repo_id = collection_repo_id
  @batch_name = batch_name
  @batch_description = batch_description
