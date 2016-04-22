require "migration_helper"

module DulHydra::Migration
  RSpec.describe Roles do

    subject { described_class.new(mover) }

    let(:mover) { double(source: source, target: target) }
    let(:f3_amd) { fixture_file_upload("migration/f3_adminMetadata.nt").read }
    let(:f3_dmd) { fixture_file_upload("migration/f3_descMetadata.nt").read }
    let(:f3_ntriples) { [ f3_amd, f3_dmd ].join("\n") }
    let(:f4_ntriples) { fixture_file_upload("migration/f4_mergedMetadata.nt").read }
    let(:source) { ::Rubydora::Datastream.new(nil, nil, content: f3_ntriples) }
    let(:target) { Item.new }

    describe "#migrate" do
      it "removes the roles from source" do
        expect { subject.migrate }.to change(source, :content).from(f3_ntriples).to(f4_ntriples)
      end
      it "adds the roles to target" do
        expect { subject.migrate }.to change { target.roles.as_json }.from({"roles"=>[]}).to({"roles"=>[{"agent"=>"repository_admins","role_type"=>"Curator","scope"=>"policy"},{"agent"=>"public","role_type"=>"Viewer","scope"=>"policy"},{"agent"=>"MetadataEditor1@duke.edu","role_type"=>"MetadataEditor","scope"=>"policy"},{"agent"=>"MetadataEditor2@duke.edu","role_type"=>"MetadataEditor","scope"=>"policy"},{"agent"=>"MetadataEditor3@duke.edu","role_type"=>"MetadataEditor","scope"=>"policy"},{"agent"=>"metadata_architects","role_type"=>"MetadataEditor","scope"=>"policy"}]})
      end
    end

  end
end
