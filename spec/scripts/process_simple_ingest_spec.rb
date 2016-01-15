require 'spec_helper'

module DulHydra::Batch::Scripts

  RSpec.describe ProcessSimpleIngest, type: :script, batch: true, simple_ingest: true do

    let(:config_hash) do
      { scanner: { exclude: [".DS_Store", "Thumbs.db", "metadata.txt"] },
        metadata:
              { csv: { encoding: "UTF-8", headers: true, col_sep: "\t" },
                parse: { repeating_fields_separator: ";",
                         repeatable_fields: ["contributor", "coverage", "creator", "extent", "identifier",
                                                "rightsHolder", "subject", "temporal"]
                       }
              }
      }
    end

    before { allow_any_instance_of(described_class).to receive(:load_configuration) { config_hash } }

    describe "#initialize" do
      context "non-existent user" do
        it "should raise a user not found error" do
          expect { ProcessSimpleIngest.new({ batch_user: 'noone@nowhere.net' }) }.to raise_error(/Unable to find user/)
        end
      end
    end

    describe "#execute" do
      let(:folder_path) { Rails.root.join('spec/fixtures/batch_ingest/simple_ingest/example') }
      let(:batch_user) {  FactoryGirl.create(:user) }
      let(:processor) { described_class.new({ batch_user: batch_user.user_key, filepath: folder_path }) }
      before { allow(processor).to receive(:get_user_choice) { 'p' } }
      it "should output the filesystem scan results" do
        expect { processor.execute }.to output(/Content models {:collections=>1, :items=>1, :components=>1}/).to_stdout
      end
      it "should produce the appropriate batch" do
        processor.execute
        batch = Ddr::Batch::Batch.last
        expect(batch.user).to eq(batch_user)
        batch_objects = batch.batch_objects
        expect(batch_objects.size).to eq(3)
        # Collection batch object
        expect(batch_objects[0].batch_object_attributes.where(name: 'title').first.value).to eq('Collection Title')
        # Item batch object
        expect(batch_objects[1].batch_object_attributes.where(name: 'title').first.value).to eq('Item A Title')
        # Component batch object
        expect(batch_objects[2].batch_object_attributes.where(name: 'title').first.value).to eq('Component 1 Title')
        content_ds = batch_objects[2].batch_object_datastreams.where(name: Ddr::Datastreams::CONTENT).first
        expect(content_ds.payload).to eq(File.join(folder_path, 'data', 'itemA', 'image1.tiff'))
        expect(content_ds.checksum).to eq('548bd2678027f3acb4d4c5ccedf6f92ca07f74bd')
      end
    end

  end

end
