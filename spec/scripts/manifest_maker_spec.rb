require 'spec_helper'

module DulHydra::Batch::Scripts
  
  shared_examples "a successful processing run" do
    let(:manifest) { DulHydra::Batch::Models::Manifest.new(manifest_file) }
    let(:objects) { manifest.objects }
    let(:object_identifiers) do
      identifiers = []
      objects.each { |object| identifiers << object.key_identifier }
      identifiers
    end
    it "should create an appropriate manifest file" do
      expect(object_identifiers).to include('image1')
      expect(object_identifiers).to include('image2')
      expect(object_identifiers).to_not include('sample')
    end
  end
  
  describe ManifestMaker do
    let(:test_dir) { Dir.mktmpdir("dul_hydra_test") }
    let(:source_path) { File.join(test_dir, 'source') }
    let(:extension) { '.tiff' }
    let(:manifest_file) { File.join(test_dir, 'manifest.yml') }
    let(:log_dir) { test_dir }
    before do
      FileUtils.mkdir(source_path)
      FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'image1.tiff'), source_path
      FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'image2.tiff'), source_path
      FileUtils.cp File.join(Rails.root, 'spec', 'fixtures', 'sample.pdf'), source_path
    end
    after do
      FileUtils.remove_dir test_dir
    end
    context "execute" do
      let(:mm) { DulHydra::Batch::Scripts::ManifestMaker.new(:dirpath => source_path, :manifest => manifest_file, :log_dir => log_dir, :include => extension) }
      before { mm.execute }
      context "successful processing run" do
        it_behaves_like "a successful processing run"
      end
    end
  end
  
end