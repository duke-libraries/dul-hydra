RSpec.describe FileDigest do

  let(:file) { fixture_file_upload('sample.pdf') }

  specify {
    path = file.path
    expect(described_class.sha1(path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
  }

  specify {
    u = URI(file.path)
    u.scheme = "file"
    path = u.to_s
    expect(described_class.sha1(path)).to eq "a6ae0d815c1a2aef551b45fe34a35ceea1828a4d"
  }

end
