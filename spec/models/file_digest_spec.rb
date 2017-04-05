RSpec.describe FileDigest do

  let(:file) { fixture_file_upload('sample.pdf') }
  let(:sha1) { 'a6ae0d815c1a2aef551b45fe34a35ceea1828a4d' }

  describe "sha1" do
    let(:repo_id) { 'test:1' }
    let(:file_id) { 'content' }
    describe "record exists" do
      before do
        described_class.create(repo_id: 'test:1', file_id: 'content', sha1: sha1)
      end
      specify {
        expect(described_class.sha1(repo_id, file_id)).to eq sha1
      }
    end
    describe "record does not exist" do
      specify {
        expect(described_class.sha1(repo_id, file_id)).to be nil
      }
    end
  end

  describe "generate_sha1" do
    specify {
      expect(described_class.generate_sha1(file.path)).to eq sha1
    }
    specify {
      expect(subject.generate_sha1(file.path)).to eq sha1
    }
  end

  describe "set_digest" do
    before do
      subject.set_digest(file.path)
    end
    its(:sha1) { is_expected.to eq sha1 }
  end

end
