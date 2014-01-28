shared_examples "a governable object" do
  let(:object) { described_class.create(:title => 'Describable', :identifier => 'id001') }
  after { object.destroy }
  describe "can have an admin policy" do
    let(:apo) { FactoryGirl.create(:admin_policy) }
    after { apo.destroy }
    it "should set its admin policy with #admin_policy= and get with #admin_policy" do
      object.admin_policy = apo
      object.save!
      ActiveFedora::Base.find(object.pid, cast: true).admin_policy.should == apo
    end
  end
  describe "#copy_admin_policy_from" do
    context "from governable object" do
      let(:other) { FactoryGirl.create(:test_model) }
      let(:apo) { FactoryGirl.create(:admin_policy) }
      before do
        other.admin_policy = apo
        other.save!
      end
      after do
        apo.destroy
        other.destroy
      end
      it "should copy the apo from the object" do
        object.copy_admin_policy_from other
        object.save!
        object.reload
        object.admin_policy.should == other.admin_policy
      end
    end
    context "from not-governable object" do
      let(:other) { ActiveFedora::Base.new }
      it "should return nil" do
        object.copy_admin_policy_from(other).should be_nil
      end
    end
  end
end
