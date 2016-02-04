require 'spec_helper'
require 'active_fedora/cleaner'
require 'fedora-migrate'

RSpec.describe 'migration' do

  let(:f3_jetty_zip_fixture) { 'f3-migration-jetty-D.zip' }
  let(:f3_jetty_zip_fixture_path) { Rails.root.join('test', 'integration', 'migration', 'fixtures', f3_jetty_zip_fixture) }
  let(:f3_temp_dir) { Dir.mktmpdir }
  let(:f3_jetty_dir) { File.join(f3_temp_dir, 'jetty') }

  before do
    module FedoraMigrate::Hooks
      def before_object_migration
        DulHydra::Migration::SourceObjectIntegrity.new(self.source).verify
        target.fcrepo3_pid = source.pid
        DulHydra::Migration::MultiresImageFilePath.new(self).migrate
        DulHydra::Migration::RDFDatastreamMerger.new(self).merge
      end
      def after_object_migration
        DulHydra::Migration::OriginalFilename.new(self).migrate if target.can_have_content?
        DulHydra::Migration::TargetObjectIntegrity.new(self.source, self.target).verify
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
    allow_any_instance_of(Rubydora::Datastream).to receive(:dsChecksumValid) { true }
  end

  after do
    Process.kill('SIGKILL', @f3_jetty_pid)
    FileUtils.remove_dir(f3_temp_dir)
  end

  it "migrates the Fedora 3 objects" do
    FedoraMigrate.migrate_repository(namespace: "duke",
                                     options: { convert: [ 'mergedMetadata' ] })
    DulHydra::Migration::MigrateStructMetadata.migrate
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
    subj = duke_1
    expect(subj).to be_a(Collection)
    expect(subj.permanent_id).to eq('ark:/99999/fk4qc07m0z')
    expect(subj.desc_metadata.spatial).to contain_exactly('Durham (N.C.)', 'North Carolina', 'United States')
    expect(subj.roles.count).to eq(2)
    expect(subj.roles.granted?(agent: 'public', role_type: 'Viewer', scope: 'policy')).to be true
    expect(subj.roles.granted?(agent: 'repo:metadata_editors', role_type: 'MetadataEditor', scope: 'policy')).to be true
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.checksum.value).to eq('200e3f3a78e0230292245dbd29193182298cd469')
    # duke:2
    subj = duke_2
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4kk9hs76')
    expect(subj.desc_metadata.extent).to contain_exactly('3.5 x 6 cm')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_1)
    expect(subj.structMetadata.mime_type).to eq('text/xml')
    expect(subj.structMetadata.content.length).to eq(439)
    expect(subj.structMetadata.content).to include(duke_3.id)
    expect(subj.structMetadata.content).to include(duke_5.id)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.checksum.value).to eq('200e3f3a78e0230292245dbd29193182298cd469')
    # duke:3
    subj = duke_3
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk4fx7hc5z')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to eq('/tmp/image-server-data/9/3/ec/93ecb451-d63e-46a4-8d13-2c596d2f73ef/dscsi010010010.ptif')
    expect(subj.roles.count).to eq(0)
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_2)
    expect(subj.content.mime_type).to eq('image/tiff')
    expect(subj.content.original_name).to eq('dscsi010010010.tif')
    expect(subj.content.checksum.value).to eq('67db06ad416d7a12b0a7e193fbe3cc971478bfd9')
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.checksum.value).to eq('200e3f3a78e0230292245dbd29193182298cd469')
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(4566)
    # duke:5
    subj = duke_5
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk4b56sk1k')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to eq('/tmp/image-server-data/e/2/22/e222c06d-eee1-4c28-9368-deb4022fd87b/dscsi010010020.ptif')
    expect(subj.roles.count).to eq(0)
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_2)
    expect(subj.content.mime_type).to eq('image/tiff')
    expect(subj.content.original_name).to eq('dscsi010010020.tif')
    expect(subj.content.checksum.value).to eq('e6ca91f2de4caa2a7246aaa323268d8357514760')
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.checksum.value).to eq('ebe2258ef66be055cb1a0da9be08577bd65c29b6')
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(4558)
    # duke:6
    subj = duke_6
    expect(subj).to be_a(Target)
    expect(subj.permanent_id).to eq('ark:/99999/fk46d62r7z')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.roles.count).to eq(0)
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.collection).to eq(duke_1)
    expect(subj.content.mime_type).to eq('image/tiff')
    expect(subj.content.original_name).to eq('dscT001.tif')
    expect(subj.content.checksum.value).to eq('9443a4dbcf2091af929ba07b4651e6991760a7d6')
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(5817)
    # duke:7
    subj = duke_7
    expect(subj).to be_a(Collection)
    expect(subj.permanent_id).to eq('ark:/99999/fk43n2cv3b')
    expect(subj.desc_metadata.temporal).to contain_exactly('2011')
    expect(subj.roles.count).to eq(3)
    expect(subj.roles.granted?(agent: 'repo:admins', role_type: 'Curator', scope: 'policy')).to be true
    expect(subj.roles.granted?(agent: 'public', role_type: 'Viewer', scope: 'policy')).to be true
    expect(subj.roles.granted?(agent: 'repo:metadata_editors', role_type: 'MetadataEditor', scope: 'policy')).to be true
    expect(subj.admin_policy).to eq(duke_7)
    # duke:8
    subj = duke_8
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4zw1p68n')
    expect(subj.desc_metadata.type).to contain_exactly('Data')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_7)
    # duke:9
    subj = duke_9
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4v40zd3r')
    expect(subj.desc_metadata.description).to contain_exactly('Project proposal')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_7)
    # duke:10
    subj = duke_10
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk4xw4n98j')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to be_nil
    expect(subj.roles.count).to eq(1)
    expect(subj.roles.granted?(agent: 'public', role_type: 'Downloader', scope: 'resource')).to be true
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_8)
    expect(subj.content.mime_type).to eq('text/comma-separated-values')
    expect(subj.content.original_name).to eq('product-list_300.csv')
    expect(subj.content.checksum.value).to eq('3aeafead5f4130932233315067d7b16c65e415f4')
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(2409)
    # duke:11
    subj = duke_11
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk42n5bz2q')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to be_nil
    expect(subj.roles.count).to eq(1)
    expect(subj.roles.granted?(agent: 'repo:project_team', role_type: 'Downloader', scope: 'resource')).to be true
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_9)
    expect(subj.content.mime_type).to eq('application/pdf')
    expect(subj.content.original_name).to eq('J20110711-00608.pdf')
    expect(subj.content.checksum.value).to eq('b4a33e872beb5ceb2a9e3c1b192c983f5500c8b9')
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(3785)
  end

end
