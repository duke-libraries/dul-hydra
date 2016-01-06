require 'spec_helper'
require 'active_fedora/cleaner'
require 'fedora-migrate'
require 'dul_hydra/migration'

RSpec.describe 'migration' do

  let(:f3_jetty_zip_fixture) { 'f3-migration-jetty-C.zip' }
  let(:f3_jetty_zip_fixture_path) { Rails.root.join('test', 'integration', 'migration', 'fixtures', f3_jetty_zip_fixture) }
  let(:f3_events_sql_fixture) { 'events-C.sql' }
  let(:f3_events_sql_fixture_path) { Rails.root.join('test', 'integration', 'migration', 'fixtures', f3_events_sql_fixture) }
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
        DulHydra::Migration::EventsMigrator.new(self).migrate
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
    ar_connection = ActiveRecord::Base.connection()
    events_sql = File.read(f3_events_sql_fixture_path)
    events_sql.split(";\n").each do |s|
      ar_connection.execute(s.strip) unless s.strip.empty?
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
    subj = duke_1
    expect(subj).to be_a(Collection)
    expect(subj.permanent_id).to eq('ark:/99999/fk4qc07m0z')
    expect(subj.desc_metadata.spatial).to contain_exactly('Durham (N.C.)', 'North Carolina', 'United States')
    expect(subj.roles.count).to eq(2)
    expect(subj.roles.granted?(agent: 'public', role_type: 'Viewer', scope: 'policy')).to be true
    expect(subj.roles.granted?(agent: 'repo:metadata_editors', role_type: 'MetadataEditor', scope: 'policy')).to be true
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.size).to eq(25037)
    expect(subj.events.count).to eq(14)
    # duke:2
    subj = duke_2
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4kk9hs76')
    expect(subj.desc_metadata.extent).to contain_exactly('3.5 x 6 cm')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_1)
    expect(subj.structMetadata.mime_type).to eq('text/xml')
    expect(subj.structMetadata.content.length).to eq(379)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.size).to eq(25037)
    expect(subj.events.count).to eq(9)
    # duke:3
    subj = duke_3
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk4fx7hc5z')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to eq('/tmp/image-server-data/0/b/4f/0b4fc12b-ce86-46e2-be6b-6ac8e2cfba6b/dscsi010010010.ptif')
    expect(subj.roles.count).to eq(0)
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_2)
    expect(subj.content.mime_type).to eq('image/tiff')
    expect(subj.content.original_name).to eq('dscsi010010010.tif')
    expect(subj.content.size).to eq(4481808)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.size).to eq(25037)
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(4566)
    expect(subj.events.count).to eq(12)
    # duke:5
    subj = duke_5
    expect(subj).to be_a(Component)
    expect(subj.permanent_id).to eq('ark:/99999/fk4b56sk1k')
    expect(subj.desc_metadata.title).to be_empty
    expect(subj.multires_image_file_path).to eq('/tmp/image-server-data/e/3/84/e3847b68-ebfa-4b28-837a-1401789947f8/dscsi010010020.ptif')
    expect(subj.roles.count).to eq(0)
    expect(subj.legacy_original_filename).to be_nil
    expect(subj.admin_policy).to eq(duke_1)
    expect(subj.parent).to eq(duke_2)
    expect(subj.content.mime_type).to eq('image/tiff')
    expect(subj.content.original_name).to eq('dscsi010010020.tif')
    expect(subj.content.size).to eq(4688604)
    expect(subj.thumbnail.mime_type).to eq('image/png')
    expect(subj.thumbnail.size).to eq(14721)
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(4558)
    expect(subj.events.count).to eq(13)
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
    expect(subj.content.size).to eq(28507714)
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(5817)
    expect(subj.events.count).to eq(11)
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
    expect(subj.events.count).to eq(12)
    # duke:8
    subj = duke_8
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4zw1p68n')
    expect(subj.desc_metadata.type).to contain_exactly('Data')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_7)
    expect(subj.events.count).to eq(7)
    # duke:9
    subj = duke_9
    expect(subj).to be_a(Item)
    expect(subj.permanent_id).to eq('ark:/99999/fk4v40zd3r')
    expect(subj.desc_metadata.description).to contain_exactly('Project proposal')
    expect(subj.roles.count).to eq(0)
    expect(subj.admin_policy).to eq(duke_7)
    expect(subj.parent).to eq(duke_7)
    expect(subj.events.count).to eq(7)
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
    expect(subj.content.size).to eq(493)
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(2409)
    expect(subj.events.count).to eq(10)
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
    expect(subj.content.size).to eq(203237)
    expect(subj.fits.mime_type).to eq('text/xml')
    expect(subj.fits.content.length).to eq(3785)
    expect(subj.events.count).to eq(12)
  end

end
