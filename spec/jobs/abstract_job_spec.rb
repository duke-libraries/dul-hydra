RSpec.describe AbstractJob do

  before(:all) do
    class TestJob
      extend AbstractJob

      @queue = :test

      def perform(object_id)
        puts object_id
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestJob)
  end

  let(:queued) do
    [{"class"=>"TestJob", "args"=>["test-1"]},
     {"class"=>"OtherJob", "args"=>["test-2"]},
     {"class"=>"TestJob", "args"=>["test-3"]},
    ]
  end

  before(:each) do
    allow(Resque).to receive(:size).with(:test) { 3 }
    allow(Resque).to receive(:peek).with(:test, 0, 3) { queued }
  end

  describe ".queued_object_ids" do
    it "returns the list of object_ids for queued jobs of this type" do
      expect(TestJob.queued_object_ids)
        .to contain_exactly("test-1", "test-3")
    end
  end

end
