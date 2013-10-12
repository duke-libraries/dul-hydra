require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful manifest making run" do
    let(:manifest) { DulHydra::Batch::Models::Manifest.new(manifest_file) }
    let(:objects) { manifest.objects }
    let(:object_identifiers) do
      identifiers = []
      objects.each { |object| identifiers << object.key_identifier }
      identifiers
    end
    let(:content_locations) do
      locations = {}
      objects.each { |object| locations[object.key_identifier] = object.object_hash['content'] }
      locations
    end
    it "should create an appropriate manifest file" do
      expect(manifest.datastream_extension('content')).to eql(ext)
      expect(object_identifiers).to include('image1')
      expect(object_identifiers).to include('image2')
      expect(object_identifiers).to_not include('sample')
      expect(content_locations).to eql(file_locations)
    end
  end
  
  describe ManifestMaker do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:source_path) { File.join(test_dir, 'source') }
    let(:ext) { '.tiff' }
    let(:file_locations) { Hash.new }
    let(:manifest_file) { File.join(test_dir, 'manifest.yml') }
    let(:log_dir) { test_dir }
    before do
      FileUtils.mkdir(source_path)
      FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'image1.tiff'), source_path
      FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'sample.pdf'), source_path
      file_locations['image1'] = File.join(source_path, 'image1.tiff')
    end
    after do
      FileUtils.remove_dir test_dir
    end
    context "non-recursive" do
      before do
        FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'), source_path
        file_locations['image2'] = File.join(source_path, 'image2.tiff')
      end
      context "execute" do
        let(:mm) { DulHydra::Batch::Scripts::ManifestMaker.new(:dirpath => source_path, :manifest => manifest_file, :log_dir => log_dir, :extension => ext) }
        before { mm.execute }
        context "successful processing run" do
          it_behaves_like "a successful manifest making run"
        end
      end
    end
    context "recursive" do
      let(:source_path_subdir) { File.join(source_path, 'subdir') }
      before do
        FileUtils.mkdir(source_path_subdir)
        FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'), source_path_subdir
        file_locations['image2'] = File.join(source_path_subdir, 'image2.tiff')
      end
      context "execute" do
        let(:mm) { DulHydra::Batch::Scripts::ManifestMaker.new(:dirpath => source_path, :manifest => manifest_file, :log_dir => log_dir, :extension => ext) }
        before { mm.execute }
        context "successful processing run" do
          it_behaves_like "a successful manifest making run"
        end
      end
    end
  end
  
end