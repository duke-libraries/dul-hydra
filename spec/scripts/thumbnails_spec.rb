require 'spec_helper'

module DulHydra::Scripts

  describe Thumbnails do

    let(:item) { FactoryGirl.create(:item, :member_of_collection, :has_part) }
    let(:collection) { item.parent }
    let(:component) { item.children.first }
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.id) }

    context "thumbnail does not exist" do

      context "child has thumbnail" do
        before do
          thumbnails_script.execute
          item.reload
        end
        it "should populate the thumbnail file from the child thumbnail" do
          expect(item.attached_files['thumbnail'].checksum.value).to eq(component.attached_files['thumbnail'].checksum.value)
        end
      end

      context "child does not have thumbnail" do
        before do
          component.attached_files['content'].content = ''
          component.save!
          component.reload
          component.attached_files['thumbnail'].content = ''
          component.save!
          thumbnails_script.execute
          item.reload
        end
        it "should not populate the thumbnail file" do
          expect(item.attached_files["thumbnail"]).to_not have_content
        end
      end

    end

    context "thumbnail already exists" do
      let(:content) { StringIO.new("awesome image") }
      before do
        item.attached_files["thumbnail"].content = content
        item.save!
        thumbnails_script.execute
        item.reload
      end
      it "should not alter the existing thumbnail" do
        expect(item.attached_files["thumbnail"].content).to eq("awesome image")
      end
    end

  end

end
