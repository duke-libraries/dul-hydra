RSpec.describe JobPerformance, type: :model do

  before(:all) {
    class TestJob
      extend AbstractJob
      @queue = "test"

      def self.perform(*args)
        puts "Testing"
      end
    end
  }

  after(:all) {
    Object.send(:remove_const, :TestJob)
  }

  describe ".enable!" do
    specify {
      expect(ActiveSupport::Notifications).to receive(:subscribe).with("perform_job.dul_hydra", described_class) { nil }
      described_class.enable!
    }
  end

  describe ".disable!" do
    specify {
      expect(ActiveSupport::Notifications).to receive(:unsubscribe).with(described_class) { nil }
      described_class.disable!
    }
  end

  describe "when subscribing to job events" do
    around(:example) do |example|
      callback = proc { |*args| described_class.call(*args) }
      ActiveSupport::Notifications.subscribed(callback, "perform_job.dul_hydra") do
        example.run
      end
    end

    specify {
      Resque.enqueue(TestJob, "foo")
      job_perf = described_class.where(job: "TestJob").first
      expect(job_perf.queue).to eq("test")
      expect(job_perf.job).to eq("TestJob")
      expect(job_perf.args).to eq(["foo"])
      expect(job_perf.started).not_to be_nil
      expect(job_perf.finished).not_to be_nil
      expect(job_perf.duration).not_to be_nil
      expect(job_perf.exception).to be_nil
      expect(job_perf.success).to be true
    }
  end
end
