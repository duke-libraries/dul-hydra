RSpec.describe PermanentId do

  describe "auto assigment" do
    let(:obj) { FactoryGirl.create(:item) }
    describe "when enabled" do
      let!(:id) { described_class.identifier_class.new("foo") }
      before do
        allow(id).to receive(:save) { nil }
        allow(described_class.identifier_class).to receive(:mint) { id }
        allow(described_class.identifier_class).to receive(:find).with("foo") { id }
        allow(DulHydra).to receive(:auto_assign_permanent_id) { true }
      end
      after do
        obj.permanent_id = nil
        obj.save!
      end
      it "assigns a permanent id to the object" do
        obj.reload
        expect(obj.permanent_id).to eq("foo")
        expect(obj.permanent_url).to eq("https://idn.duke.edu/foo")
      end
    end
    describe "when disabled" do
      before do
        allow(DulHydra).to receive(:auto_assign_permanent_id) { false }
      end
      it "does not assign a permanent id to the object" do
        expect(obj.reload.permanent_id).to be_nil
      end
    end
  end

  describe "assignment" do
    let(:obj) { FactoryGirl.create(:item) }
    let!(:id) { described_class.identifier_class.new("foo") }
    before do
      allow(id).to receive(:save) { nil }
      allow(described_class.identifier_class).to receive(:mint) { id }
      allow(described_class.identifier_class).to receive(:find).with("foo") { id }
    end
    after do
      obj.permanent_id = nil
      obj.save!
    end
    it "creates an update event" do
      expect { described_class.assign!(obj) }.to change(Ddr::Events::UpdateEvent, :count).to(1)
    end
  end

  describe "updating" do
    let(:obj) { Item.create(pid: "test:1") }
    let!(:id) { described_class.identifier_class.new("foo") }
    before do
      allow(described_class.identifier_class).to receive(:find).with("foo") { id }
    end
    describe "when the object workflow state changes" do
      describe "and the object has a permanent id" do
        before do
          allow(id).to receive(:save) { nil }
          obj.permanent_id = "foo"
        end
        after do
          obj.permanent_id = nil
          obj.save!
        end
        it "updates the permanent id" do
          expect { obj.publish! }.to change(id, :status).to("public")
        end
      end
      describe "and the object does not have a permanent id" do
        it "does not update the permanent id" do
          expect { obj.publish! }.not_to change(id, :status)
        end
      end
    end
    describe "when the object workflow state does not change" do
      it "does not update the permanent id" do
        expect { obj.save! }.not_to change(id, :status)
      end
    end
  end

  describe "deleting / marking unavailable" do
    describe "when an object has a permanent id" do
      let(:obj) { Item.create(pid: "test:1", permanent_id: "foo") }
      let!(:id) { described_class.identifier_class.new("foo") }
      before do
        allow(id).to receive(:save) { nil }
        allow(described_class.identifier_class).to receive(:find).with("foo") { id }
      end
      describe "and it's deacessioned" do
        specify {
          expect(described_class).to receive(:deaccession!).with("test:1", "foo", nil) { nil }
          obj.deaccession
        }
      end
      describe "and it's deleted" do
        specify {
          expect(described_class).not_to receive(:delete!)
          expect(described_class).not_to receive(:deaccession!)
          obj.send(:delete)
        }
      end
      describe "and it's destroyed" do
        specify {
          expect(described_class).to receive(:delete!).with("test:1", "foo", nil) { nil }
          obj.destroy
        }
      end
    end
    describe "when an object does not have a permanent id" do
      let(:obj) { FactoryGirl.create(:item) }
      describe "and it's deacessioned" do
        specify {
          expect(described_class).not_to receive(:deaccession!)
          obj.deaccession
        }
      end
      describe "and it's deleted" do
        specify {
          expect(described_class).not_to receive(:deaccession!)
          expect(described_class).not_to receive(:delete!)
          obj.send(:delete)
        }
      end
      describe "and it's destroyed" do
        specify {
          expect(described_class).not_to receive(:delete!)
          obj.destroy
        }
      end
    end
  end

  describe "constructor" do
    describe "when the object is new" do
      let(:obj) { FactoryGirl.build(:item) }
      it "raises an error" do
        expect { described_class.new(obj) }.to raise_error(PermanentId::RepoObjectNotPersisted)
      end
    end
    describe "when passed a repo object id" do
      let(:obj) { FactoryGirl.create(:item) }
      subject { described_class.new(obj.id) }
      its(:repo_id) { is_expected.to eq(obj.id) }
    end
  end

  describe "instance methods" do
    let(:obj) { FactoryGirl.create(:item) }
    subject { described_class.new(obj) }

    describe "#assign!" do
      describe "when the object already has a permanent identifier" do
        before { obj.permanent_id = "foo" }
        it "raises an error" do
          expect { subject.assign! }.to raise_error(PermanentId::AlreadyAssigned)
          expect { subject.assign!("bar") }.to raise_error(PermanentId::AlreadyAssigned)
        end
      end
      describe "when the object does not have a permanent identifier" do
        let(:obj) { FactoryGirl.create(:item) }
        let!(:id) { described_class.identifier_class.new("foo") }
        before do
          allow(described_class.identifier_class).to receive(:find).with("foo") { id }
          allow(id).to receive(:save) { nil }
          allow(obj).to receive(:save) { true }
        end
        describe "when passed an ARK" do
          before do
            subject.assign!("foo")
          end
          it "assigns the ARK" do
            expect(obj.permanent_id).to eq("foo")
          end
          it "sets the target on the identifier" do
            expect(id.target).to eq("https://repository.duke.edu/id/foo")
          end
          it "sets the status on the identifier" do
            expect(id.status).to eq("reserved")
          end
          it "sets the repository id on the identifier" do
            expect(id["fcrepo3.pid"]).to eq(obj.id)
          end
        end
        describe "when not passed an ARK" do
          before do
            subject.assign!("foo")
            allow(described_class.identifier_class).to receive(:mint) { id }
          end
          it "mints and assigns an ARK" do
            expect(obj.permanent_id).to eq("foo")
          end
          it "sets the target on the identifier" do
            expect(id.target).to eq("https://repository.duke.edu/id/foo")
          end
          it "sets the status on the identifier" do
            expect(id.status).to eq("reserved")
          end
          it "sets the repository id on the identifier" do
            expect(id["fcrepo3.pid"]).to eq(obj.id)
          end
        end
      end
    end

    describe "#update!" do
      describe "when the object has not been assigned a permanent id" do
        it "raises an error" do
          expect { subject.update! }.to raise_error(PermanentId::IdentifierNotAssigned)
        end
      end
      describe "when the object has been assigned a permanent id" do
        let!(:id) { described_class.identifier_class.new("foo") }
        before do
          allow(described_class.identifier_class).to receive(:find).with("foo") { id }
          obj.permanent_id = "foo"
        end
        it "sets the status on the permanent id" do
          expect(subject).to receive(:set_status!) { nil }
          subject.update!
        end
      end
    end

    describe "#deaccession!" do
      let!(:id) { described_class.identifier_class.new("foo") }
      subject { described_class.new("test:1", "foo") }
      before do
        allow(described_class.identifier_class).to receive(:find).with("foo") { id }
      end
      specify {
        expect(id).to receive(:delete)
        subject.deaccession!
      }
      describe " when the identifier is not reserved" do
        before { id.public! }
        specify {
          expect(id).to receive(:unavailable!).with("deaccessioned")
          subject.deaccession!
        }
      end
      describe "when the identifier is associated with another repo id" do
        before { subject.identifier_repo_id = "test:2" }
        specify {
          expect { subject.deaccession! }.to raise_error(PermanentId::Error)
        }
      end
    end

    describe "#delete!" do
      let!(:id) { described_class.identifier_class.new("foo") }
      subject { described_class.new("test:1", "foo") }
      before do
        allow(described_class.identifier_class).to receive(:find).with("foo") { id }
      end
      specify {
        expect(id).to receive(:delete)
        subject.delete!
      }
      describe " when the identifier is not reserved" do
        before { id.public! }
        specify {
          expect(id).to receive(:unavailable!).with("deleted")
          subject.delete!
        }
      end
      describe "when the identifier is associated with another repo id" do
        before { subject.identifier_repo_id = "test:2" }
        specify {
          expect { subject.delete! }.to raise_error(PermanentId::Error)
        }
      end
    end

    describe "identifier metadata" do
      let(:obj) { Item.create(pid: "test:1") }
      let!(:id) { described_class.identifier_class.new("foo") }
      subject { described_class.new(obj) }
      before do
        allow(subject).to receive(:identifier) { id }
      end
      describe "#identifier_repo_id" do
        before do
          allow(id).to receive(:[]).with("fcrepo3.pid") { "test:1" }
        end
        its(:identifier_repo_id) { is_expected.to eq("test:1") }
      end
      describe "#identifier_repo_id=" do
        specify {
          subject.identifier_repo_id = "test:1"
          expect(id["fcrepo3.pid"]).to eq("test:1")
        }
        describe "when a value was previously assigned" do
          before { subject.identifier_repo_id = "test:1" }
          specify {
            expect { subject.identifier_repo_id = "test:2" }.to raise_error(PermanentId::Error)
          }
        end
      end
      describe "#set_identifier_repo_id" do
        specify {
          subject.set_identifier_repo_id
          expect(subject.identifier_repo_id).to eq("test:1")
        }
      end
      describe "#set_target" do
        specify {
          subject.set_target
          expect(subject.target).to eq("https://repository.duke.edu/id/foo")
        }
      end
      describe "#set_status" do
        describe "when object is published" do
          before { obj.workflow_state = "published" }
          describe "and identifier is public" do
            before { subject.public! }
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
          describe "and identifier is reserved" do
            it "changes to public" do
              expect { subject.set_status }.to change(subject, :status).to("public")
            end
          end
          describe "and identifier is unavailable" do
            before { subject.unavailable! }
            it "changes to public" do
              expect { subject.set_status }.to change(subject, :status).to("public")
            end
          end
        end
        describe "when object is unpublished" do
          before { obj.workflow_state = "unpublished" }
          describe "and identifier is public" do
            before { subject.public! }
            it "changes to unavailable" do
              expect { subject.set_status }.to change(subject, :status).to("unavailable | not published")
            end
          end
          describe "and identifier is reserved" do
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
          describe "and identifier is unavailable" do
            before { subject.unavailable! }
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
        end
        describe "when object has no workflow state" do
          describe "and identifier is public" do
            before { subject.public! }
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
          describe "and identifier is reserved" do
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
          describe "and identifier is unavailable" do
            before { subject.unavailable! }
            it "does not change" do
              expect { subject.set_status }.not_to change(subject, :status)
            end
          end
        end
      end
    end
  end
end
