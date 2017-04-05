RSpec.describe DeletedFile do

  before do
    allow(Ddr::Derivatives).to receive(:update_derivatives) { [] }
    @obj = FactoryGirl.create(:component)
  end

  describe "object" do
    before do
      @last_modified = @obj.modified_date
      @content_path = @obj.content.file_path
      @content_modified = @obj.content.createDate
      @descmd_modified = @obj.descMetadata.createDate
      @obj.destroy
    end

    describe "object record" do
      subject {
        DeletedFile.find_by!(repo_id: @obj.id, source: "FOXML")
      }
      its(:file_id) { is_expected.to be_nil }
      its(:version_id) { is_expected.to be_nil }
      its(:path) { is_expected.to be_nil }
      its(:last_modified) { is_expected.to eq @last_modified }
    end

    describe "datastreams" do
      describe "external datastream" do
        subject {
          DeletedFile.find_by!(repo_id: @obj.id, file_id: 'content')
        }
        its(:version_id) { is_expected.to eq 'content.0' }
        its(:path) { is_expected.to eq @content_path }
        its(:last_modified) { is_expected.to eq @content_modified }
        its(:source) { is_expected.to eq "F3-DS-E" }
      end
      describe "managed datastream" do
        subject {
          DeletedFile.find_by!(repo_id: @obj.id, file_id: 'descMetadata')
        }
        its(:version_id) { is_expected.to eq 'descMetadata.0' }
        its(:path) { is_expected.to be_nil }
        its(:last_modified) { is_expected.to eq @descmd_modified }
        its(:source) { is_expected.to eq "F3-DS-M" }
      end
    end
  end

  describe "datastreams" do
    describe "external datastream" do
      before do
        @last_modified = @obj.content.createDate
        @path = @obj.content.file_path
        @obj.content.delete
      end
      subject {
        DeletedFile.find_by!(repo_id: @obj.id, file_id: 'content')
      }
      its(:version_id) { is_expected.to eq 'content.0' }
      its(:path) { is_expected.to eq @path }
      its(:last_modified) { is_expected.to eq @last_modified }
      its(:source) { is_expected.to eq "F3-DS-E" }
    end

    describe "managed datastream" do
      before do
        @last_modified = @obj.descMetadata.createDate
        @obj.descMetadata.delete
      end
      subject {
        DeletedFile.find_by!(repo_id: @obj.id, file_id: 'descMetadata')
      }
      its(:version_id) { is_expected.to eq 'descMetadata.0' }
      its(:path) { is_expected.to be_nil }
      its(:last_modified) { is_expected.to eq @last_modified }
      its(:source) { is_expected.to eq "F3-DS-M" }
    end
  end

  describe "a complex example" do
    before do
      @content0_path = @obj.content.file_path
      @content0_mod = @obj.content.createDate
      @descmd0_mod = @obj.descMetadata.createDate
      @obj.title = ["Title Changed"]
      @obj.upload fixture_file_upload("imageA.jpg", "image/jpeg")
      @obj.save!
      @content1_path = @obj.content.file_path
      @content1_mod = @obj.content.createDate
      @descmd1_mod = @obj.descMetadata.createDate
      @obj.title = ["Title Changed Again"]
      @obj.save!
      @descmd2_mod = @obj.descMetadata.createDate
      @last_modified = @obj.modified_date
      @obj.destroy
    end
    specify {
      foxml = DeletedFile.find_by!(repo_id: @obj.id, source: "FOXML")
      expect(foxml.last_modified).to eq @last_modified
      expect(foxml.file_id).to be_nil
      expect(foxml.version_id).to be_nil
      expect(foxml.path).to be_nil

      content = DeletedFile.where(repo_id: @obj.id, file_id: 'content')
      expect(content.size).to eq 2
      content.each do |c|
        expect(c.source).to eq "F3-DS-E"
        expect(c.version_id).to be_present
        expect(c.path).to be_present
      end

      content0 = DeletedFile.find_by!(repo_id: @obj.id, file_id: 'content', version_id: 'content.0')
      expect(content0.path).to eq @content0_path
      expect(content0.last_modified).to eq @content0_mod

      content1 = DeletedFile.find_by!(repo_id: @obj.id, file_id: 'content', version_id: 'content.1')
      expect(content1.path).to eq @content1_path
      expect(content1.last_modified).to eq @content1_mod

      descmd = DeletedFile.where(repo_id: @obj.id, file_id: 'descMetadata')
      expect(descmd.size).to eq 3
      descmd.each do |d|
        expect(d.source).to eq "F3-DS-M"
        expect(d.version_id).to be_present
        expect(d.path).to be_nil
      end

      descmd0 = DeletedFile.find_by!(repo_id: @obj.id, file_id: 'descMetadata', version_id: 'descMetadata.0')
      expect(descmd0.last_modified).to eq @descmd0_mod
      descmd1 = DeletedFile.find_by!(repo_id: @obj.id, file_id: 'descMetadata', version_id: 'descMetadata.1')
      expect(descmd1.last_modified).to eq @descmd1_mod
      descmd2 = DeletedFile.find_by!(repo_id: @obj.id, file_id: 'descMetadata', version_id: 'descMetadata.2')
      expect(descmd2.last_modified).to eq @descmd2_mod
    }
  end

end
