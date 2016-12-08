RSpec.describe PermanentId do

  let(:obj) { FactoryGirl.create(:item) }

  describe "defaults" do
    subject { described_class.new("foo") }
    its(:profile) { is_expected.to eq("dc") }
    its(:export) { is_expected.to eq("no") }
    its(:status) { is_expected.to eq("reserved") }
  end

  describe ".assign!" do
    describe "when the object is new" do
      let(:obj) { FactoryGirl.build(:item) }
      it "raises an error" do
        expect { described_class.assign!(obj) }.to raise_error(PermanentId::ObjectNotPersisted)
      end
    end
    describe "when the object already has a permanent identifier" do
      before { obj.permanent_id = "foo" }
      it "raises an error" do
        expect { described_class.assign!(obj) }.to raise_error(PermanentId::AlreadyAssigned)
        expect { described_class.assign!(obj, ark: "bar") }.to raise_error(PermanentId::AlreadyAssigned)
      end
    end
    describe "when the object does not have a permanent identifier" do
      let!(:id) { described_class.new("foo") }
      before do
        allow(described_class).to receive(:find).with("foo") { id }
        allow(id).to receive(:save) { nil }
        allow(obj).to receive(:save) { nil }
      end
      describe "when passed an ARK" do
        before do
          described_class.assign!(obj, ark: "foo")
        end
        it "assigns the ARK" do
          expect(obj.permanent_id).to eq("foo")
          expect(id.repo_id).to eq(obj.id)
          expect(id.target).to eq("https://repository.duke.edu/id/foo")
          expect(id.status).to eq("reserved")
        end
      end
      describe "when not passed an ARK" do
        before do
          allow(described_class).to receive(:mint) { id }
          described_class.assign!(obj, ark: "foo")
        end
        it "mints and ARK and assigns it" do
          expect(obj.permanent_id).to eq("foo")
          expect(id.repo_id).to eq(obj.id)
          expect(id.target).to eq("https://repository.duke.edu/id/foo")
          expect(id.status).to eq("reserved")
        end
      end
    end
  end

  describe "#repo_id" do
    subject { described_class.new("foo", "fcrepo3.pid"=>"test:1") }
    its(:repo_id) { is_expected.to eq("test:1") }
  end

  describe "#repo_id=" do
    subject { described_class.new("foo") }
    specify {
      subject.repo_id = "test:1"
      expect(subject["fcrepo3.pid"]).to eq("test:1")
    }
    describe "when a value was previously assigned" do
      before { subject.repo_id = "test:1" }
      specify {
        expect { subject.repo_id = "test:2" }.to raise_error(PermanentId::Error)
      }
    end
  end

  describe "#set_repo_id" do
    let(:obj) { Item.new(pid: "test:1") }
    subject { described_class.new("foo") }
    specify {
      subject.set_repo_id(obj)
      expect(subject.repo_id).to eq("test:1")
    }
  end

  describe "#set_target" do
    subject { described_class.new("foo") }
    specify {
      subject.set_target
      expect(subject.target).to eq("https://repository.duke.edu/id/foo")
    }
  end

  describe "#set_status" do
    subject { described_class.new("foo") }
    let(:obj) { FactoryGirl.build(:item) }
    describe "when object is published" do
      before { obj.workflow_state = "published" }
      describe "and identifier is public" do
        before { subject.public! }
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
      describe "and identifier is reserved" do
        it "changes to public" do
          expect { subject.set_status(obj) }.to change(subject, :status).to("public")
        end
      end
      describe "and identifier is unavailable" do
        before { subject.unavailable! }
        it "changes to public" do
          expect { subject.set_status(obj) }.to change(subject, :status).to("public")
        end
      end
    end
    describe "when object is unpublished" do
      before { obj.workflow_state = "unpublished" }
      describe "and identifier is public" do
        before { subject.public! }
        it "changes to unavailable" do
          expect { subject.set_status(obj) }.to change(subject, :status).to("unavailable | not published")
        end
      end
      describe "and identifier is reserved" do
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
      describe "and identifier is unavailable" do
        before { subject.unavailable! }
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
    end
    describe "when object has no workflow state" do
      describe "and identifier is public" do
        before { subject.public! }
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
      describe "and identifier is reserved" do
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
      describe "and identifier is unavailable" do
        before { subject.unavailable! }
        it "does not change" do
          expect { subject.set_status(obj) }.not_to change(subject, :status)
        end
      end
    end
  end

end
