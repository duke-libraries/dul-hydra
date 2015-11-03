require 'spec_helper'

RSpec.describe METSFile, type: :model, batch: true, mets_file: true do

  let(:collection) { Collection.new }
  let(:mets_filepath) { '/tmp/mets.xml' }
  let(:subject) { METSFile.new(mets_filepath, collection) }

  before do
    allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml }
    allow(Ddr::Utils).to receive(:pid_for_identifier) { 'test-5' }
    allow(ActiveFedora::SolrService).to receive(:query).with("{!terms f=id}test-5") { [ { "active_fedora_model_ssi"=>"Item" } ] }
  end

  its(:local_id) { is_expected.to eq('efghi01003') }
  its(:collection_id) { is_expected.to eq('abcd') }
  its(:collection) { is_expected.to eq(collection) }
  its(:repo_pid) { is_expected.to eq('test-5') }
  its(:repo_model) { is_expected.to eq('Item') }
  its(:root_type_attr) { is_expected.to eq('Resource:slideshow') }
  its(:header_agent_id) { is_expected.to eq('library')}

  # public methods currently untested
  # dmd_secs
  # dmd_sec
  # desc_metadata
  # struct_maps
  # struct_map
  # struct_metadata

end