RSpec.describe FileDigestManager do

  before(:each) do
    obj.descMetadata.title = [ "Title" ]
    obj.content.dsLocation = Ddr::Utils.path_to_uri(file.path)
    obj.save!
  end

  let(:file) { fixture_file_upload('sample.pdf') }
  let(:obj) { Component.new(pid: 'testfdm:1') }

  it "creates sha1 and md5 digests for external files" do
    file_digest = FileDigest.find_by_repo_id_and_file_id!('testfdm:1', 'content')
    expect(file_digest.path).to eq file.path
    expect(file_digest.sha1).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
    expect(file_digest.md5).to eq "4f3f9c99a9f2720b77870371ff21ea9f"
  end

  it "updates the sha1 digest for an external file" do
    new_file = fixture_file_upload('sample.docx')
    file_digest = FileDigest.find_by_repo_id_and_file_id!('testfdm:1', 'content')
    expect {
      obj.content.dsLocation = Ddr::Utils.path_to_uri(new_file.path)
      obj.save!
      file_digest.reload
    }.to change(file_digest, :sha1).to("ff01aab0eada29d35bb423c5c73a9f67a22bc1fd")
  end

  it "updates the md5 digest for an external file" do
    new_file = fixture_file_upload('sample.docx')
    file_digest = FileDigest.find_by_repo_id_and_file_id!('testfdm:1', 'content')
    expect {
      obj.content.dsLocation = Ddr::Utils.path_to_uri(new_file.path)
      obj.save!
      file_digest.reload
    }.to change(file_digest, :md5).to("b0181c7f5fb49b08ec3a9768c9fd07b4")
  end

  it "updates the path for an external file" do
    new_file = fixture_file_upload('sample.docx')
    file_digest = FileDigest.find_by_repo_id_and_file_id!('testfdm:1', 'content')
    expect {
      obj.content.dsLocation = Ddr::Utils.path_to_uri(new_file.path)
      obj.save!
      file_digest.reload
    }.to change(file_digest, :path)
  end

  it "does not create a file digest for non-external files" do
    expect { FileDigest.find_by_repo_id_and_file_id!('testfdm:1', 'descMetadata') }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "deletes the file digests when the object is deleted" do
    obj.destroy
    expect(FileDigest.where(repo_id: obj.id)).to be_empty
  end

  it "deletes the file digest when the datastream is deleted" do
    obj.content.delete
    expect(FileDigest.where(repo_id: obj.id, file_id: 'content')).to be_empty
  end

end
