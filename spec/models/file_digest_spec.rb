RSpec.describe FileDigest do

  let(:file) { fixture_file_upload('sample.pdf') }

  describe "generate_sh1" do
    specify {
      expect(described_class.generate_sha1(file.path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
    }
    specify {
      expect(subject.generate_sha1(file.path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
    }
  end

  describe "set_digest" do
    before do
      subject.set_digest(file.path)
    end
    its(:sha1) { is_expected.to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d" }
  end

end
