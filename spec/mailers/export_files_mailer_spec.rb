RSpec.describe ExportFilesMailer do

  let(:user) { FactoryGirl.create(:user) }

  describe "notify_failure" do
    it "works" do
      described_class.notify_failure(["test:1"], "foo", user).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to match /FAILED/
    end
  end

  describe "notify_success" do
    it "works" do
      export = ExportFiles::Package.new(["test:1"])
      described_class.notify_success(export, user).deliver_now!
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to match /COMPLETED/
    end
  end

end
