require 'spec_helper'
require 'active_fedora/cleaner'
require 'fedora-migrate'
require 'dul_hydra/migration'

RSpec.describe 'migration' do

  let(:f3_jetty_zip_fixture) { 'f3-migration-jetty-C.zip' }
  let(:f3_jetty_zip_fixture_path) { Rails.root.join('test', 'integration', 'migration', 'fixtures', f3_jetty_zip_fixture) }
  let(:f3_temp_dir) { Dir.mktmpdir }
  let(:f3_jetty_dir) { File.join(f3_temp_dir, 'jetty') }

  before do
    module FedoraMigrate::Hooks
      def before_object_migration
        target.fcrepo3_pid = source.pid
        DulHydra::Migration::MultiresImageFilePath.new(self).migrate
        DulHydra::Migration::RDFDatastreamMerger.new(self).merge
      end
      def after_object_migration
        DulHydra::Migration::OriginalFilename.new(self).migrate if target.can_have_content?
      end
      def before_rdf_datastream_migration
        if source.dsid == "mergedMetadata"
          DulHydra::Migration::Roles.new(self).migrate
        end
      end
      def after_datastream_migration
        target.original_name = nil # fedora-migrate uses dsLabel to set original_name
      end
    end
    ActiveFedora::Cleaner.clean!
    `rm -r #{File.join(Rails.root, 'migration_report')}`
    `unzip #{f3_jetty_zip_fixture_path} -d #{f3_temp_dir}`
    Dir.chdir("#{f3_jetty_dir}") do
      @f3_jetty_pid = spawn('java -Djetty.port=8984 -Dsolr.solr.home=solr -Xmx256m -jar start.jar')
      sleep 45
    end
  end

  after do
    Process.kill('SIGKILL', @f3_jetty_pid)
    FileUtils.remove_dir(f3_temp_dir)
  end

  it "migrates the Fedora 3 objects" do
    FedoraMigrate.migrate_repository(namespace: "duke",
                                     options: { convert: [ 'mergedMetadata' ] })
    duke_1 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:1').first
    duke_2 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:2').first
    duke_3 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:3').first
    duke_5 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:5').first
    duke_6 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:6').first
    duke_7 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:7').first
    duke_8 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:8').first
    duke_9 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:9').first
    duke_10 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:10').first
    duke_11 = ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => 'duke:11').first
    # duke:1
    expect(duke_1).to be_a(Collection)
    expect(duke_1.permanent_id).to eq('ark:/99999/fk4qc07m0z')
    expect(duke_1.desc_metadata.spatial).to contain_exactly('Durham (N.C.)', 'North Carolina', 'United States')
    expect(duke_1.roles.count).to eq(2)
    expect(duke_1.roles.granted?(agent: 'public', role_type: 'Viewer', scope: 'policy')).to be true
    expect(duke_1.roles.granted?(agent: 'repo:metadata_editors', role_type: 'MetadataEditor', scope: 'policy')).to be true
    # duke:2
    expect(duke_2).to be_a(Item)
    expect(duke_2.permanent_id).to eq('ark:/99999/fk4kk9hs76')
    expect(duke_2.desc_metadata.extent).to contain_exactly('3.5 x 6 cm')
    expect(duke_2.roles.count).to eq(0)
    # duke:3
    expect(duke_3).to be_a(Component)
    expect(duke_3.permanent_id).to eq('ark:/99999/fk4fx7hc5z')
    expect(duke_3.desc_metadata.title).to be_empty
    expect(duke_3.multires_image_file_path).to eq('/tmp/image-server-data/0/b/4f/0b4fc12b-ce86-46e2-be6b-6ac8e2cfba6b/dscsi010010010.ptif')
    expect(duke_3.roles.count).to eq(0)
    expect(duke_3.content.original_name).to eq('dscsi010010010.tif')
    expect(duke_3.legacy_original_filename).to be_nil
    # duke:5
    expect(duke_5).to be_a(Component)
    expect(duke_5.permanent_id).to eq('ark:/99999/fk4b56sk1k')
    expect(duke_5.desc_metadata.title).to be_empty
    expect(duke_5.multires_image_file_path).to eq('/tmp/image-server-data/e/3/84/e3847b68-ebfa-4b28-837a-1401789947f8/dscsi010010020.ptif')
    expect(duke_5.roles.count).to eq(0)
    expect(duke_5.content.original_name).to eq('dscsi010010020.tif')
    expect(duke_5.legacy_original_filename).to be_nil
    # duke:6
    expect(duke_6).to be_a(Target)
    expect(duke_6.permanent_id).to eq('ark:/99999/fk46d62r7z')
    expect(duke_6.desc_metadata.title).to be_empty
    expect(duke_6.roles.count).to eq(0)
    expect(duke_6.content.original_name).to eq('dscT001.tif')
    expect(duke_6.legacy_original_filename).to be_nil
    # duke:7
    expect(duke_7).to be_a(Collection)
    expect(duke_7.permanent_id).to eq('ark:/99999/fk43n2cv3b')
    expect(duke_7.desc_metadata.temporal).to contain_exactly('2011')
    expect(duke_7.roles.count).to eq(3)
    expect(duke_7.roles.granted?(agent: 'repo:admins', role_type: 'Curator', scope: 'policy')).to be true
    expect(duke_7.roles.granted?(agent: 'public', role_type: 'Viewer', scope: 'policy')).to be true
    expect(duke_7.roles.granted?(agent: 'repo:metadata_editors', role_type: 'MetadataEditor', scope: 'policy')).to be true
    # duke:8
    expect(duke_8).to be_a(Item)
    expect(duke_8.permanent_id).to eq('ark:/99999/fk4zw1p68n')
    expect(duke_8.desc_metadata.type).to contain_exactly('Data')
    expect(duke_8.roles.count).to eq(0)
    # duke:9
    expect(duke_9).to be_a(Item)
    expect(duke_9.permanent_id).to eq('ark:/99999/fk4v40zd3r')
    expect(duke_9.desc_metadata.description).to contain_exactly('Project proposal')
    expect(duke_9.roles.count).to eq(0)
    # duke:10
    expect(duke_10).to be_a(Component)
    expect(duke_10.permanent_id).to eq('ark:/99999/fk4xw4n98j')
    expect(duke_10.desc_metadata.title).to be_empty
    expect(duke_10.multires_image_file_path).to be_nil
    expect(duke_10.roles.count).to eq(1)
    expect(duke_10.roles.granted?(agent: 'public', role_type: 'Downloader', scope: 'resource')).to be true
    expect(duke_10.content.original_name).to eq('product-list_300.csv')
    expect(duke_10.legacy_original_filename).to be_nil
    # duke:11
    expect(duke_11).to be_a(Component)
    expect(duke_11.permanent_id).to eq('ark:/99999/fk42n5bz2q')
    expect(duke_11.desc_metadata.title).to be_empty
    expect(duke_11.multires_image_file_path).to be_nil
    expect(duke_11.roles.count).to eq(1)
    expect(duke_11.roles.granted?(agent: 'repo:project_team', role_type: 'Downloader', scope: 'resource')).to be true
    expect(duke_11.content.original_name).to eq('J20110711-00608.pdf')
    expect(duke_11.legacy_original_filename).to be_nil
  end

end
