require 'spec_helper'
require 'fedora-migrate'

RSpec.describe 'migration' do

  let(:f3_jetty_zip_fixture) { 'f3-migration-jetty-B.zip' }
  let(:f3_jetty_zip_fixture_path) { Rails.root.join('test', 'integration', 'migration', 'fixtures', f3_jetty_zip_fixture) }
  let(:f3_temp_dir) { Dir.mktmpdir }
  let(:f3_jetty_dir) { File.join(f3_temp_dir, 'jetty') }

  before do
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
                                     options: { convert: [ 'descMetadata', 'adminMetadata' ] })
    expect(ActiveFedora::Base.count).to eq(10)
    expect(Collection.count).to eq(2)
    expect(Item.count).to eq(3)
    expect(Component.count).to eq(4)
    expect(Target.count).to eq(1)
    expect(Attachment.count).to eq(0)
  end

end
