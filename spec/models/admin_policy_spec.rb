require 'spec_helper'

describe AdminPolicy do
  context "terms delegated to defaultRights" do
    let(:apo) { AdminPolicy.new }
    before do
      apo.default_license_title = "License Title"
      apo.default_license_description = "License Description"
      apo.default_license_url = "http://library.duke.edu"
    end
    it "should set the terms correctly" do
      apo.defaultRights.license.title.first.should == "License Title"
      apo.defaultRights.license.description.first.should == "License Description"
      apo.defaultRights.license.url.first.should == "http://library.duke.edu"
    end
  end

  context "validation" do
    let(:apo) { AdminPolicy.new }
    context "of title attribute" do
      context "presence" do
        it "should be required" do
          expect(apo).not_to be_valid
          expect(apo.errors[:title]).to include("can't be blank")
        end
      end
      context "uniqueness" do
        before do
          allow(AdminPolicy).to receive(:where).with("title_ssi" => "My Title") do
            [AdminPolicy.new(title: "My Title")] 
          end
          apo.title = "My Title"
        end
        it "should be required" do
          expect(apo).not_to be_valid
          expect(apo.errors[:title]).to include("has already been taken")
        end
      end
    end
  end

  context "#set_initial_permissions" do
    let(:apo) { AdminPolicy.new }
    context "no user creator" do
      before { apo.set_initial_permissions }
      it "should have registered read access" do
        apo.permissions.should == [Hydra::AccessControls::Permission.new(DulHydra::Permissions::REGISTERED_READ_ACCESS)]
      end
    end
    context "user creator" do
      let(:user) { FactoryGirl.build(:user) }
      before { apo.set_initial_permissions(user) }
      it "should have user edit access" do
        apo.edit_users.should == [user.to_s]
      end      
      it "should have registered read access" do
        apo.read_groups.should == ["registered"]
      end
    end
  end

  context "indexing" do
    subject { SolrDocument.new(ActiveFedora::SolrService.query(ActiveFedora::SolrService.construct_query_for_pids([apo.pid])).first) }
    let(:apo) { AdminPolicy.create(title: 'Awesome Policy') }
    its(:title) { should == apo.title }
  end

end
