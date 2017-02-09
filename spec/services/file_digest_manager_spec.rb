RSpec.describe FileDigestManager do

  before(:all) do
    class TestFileDigestManager < Ddr::Models::Base
      include Ddr::Models::HasContent
      include Ddr::Models::Describable
      has_file_datastream name: "e_content", control_group: "E"
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestFileDigestManager)
  end

  before(:each) do
    file = fixture_file_upload('sample.pdf')
    obj.descMetadata.title = [ "Title" ]
    obj.e_content.dsLocation = Ddr::Utils.path_to_uri(file.path)
    obj.save!
  end

  let(:obj) { TestFileDigestManager.new(pid: 'testfdm:1') }

  it "creates a file digest for external files" do
    file_digest = FileDigest.find_by_repo_id_and_file_id!(obj.id, 'e_content')
    expect(file_digest.sha1).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
  end

  it "updates the file digest for an external file" do
    new_file = fixture_file_upload('sample.docx')
    file_digest = FileDigest.find_by_repo_id_and_file_id!(obj.id, 'e_content')
    expect {
      obj.e_content.dsLocation = Ddr::Utils.path_to_uri(new_file.path)
      obj.save!
      file_digest.reload
    }.to change(file_digest, :sha1).to("ff01aab0eada29d35bb423c5c73a9f67a22bc1fd")
  end

  it "does not create a file digest for non-external files" do
    expect { FileDigest.find_by_repo_id_and_file_id!(obj.id, 'descMetadata') }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "deletes the file digests when the object is deleted" do
    obj.destroy
    expect(FileDigest.where(repo_id: obj.id)).to be_empty
  end

  it "deletes the file digest when the datastream is deleted" do
    obj.e_content.delete
    expect(FileDigest.where(repo_id: obj.id)).to be_empty
  end

end
