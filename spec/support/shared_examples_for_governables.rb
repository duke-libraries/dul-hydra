shared_examples "a governable object" do
  let(:object) do
    described_class.new.tap do |obj|
      obj.title = 'Describable'
      obj.identifier = 'id001'
      obj.save(validate: false)
    end
  end
  describe "can have an admin policy" do
    let(:apo) { FactoryGirl.create(:admin_policy) }
    after { apo.destroy }
    it "should set its admin policy with #admin_policy= and get with #admin_policy" do
      object.admin_policy = apo
      object.save(validate: false)
      ActiveFedora::Base.find(object.pid, cast: true).admin_policy.should == apo
    end
  end
end
