require 'spec_helper'

describe "batches/index.html.erb", :type => :feature do
  context "ingest folders" do
    let(:user) { FactoryGirl.create(:user) }
    let(:menu_label) { I18n.t('dul_hydra.ingest_folder.new_menu') }
    before { login_as user }
    context "user has no permitted ingest folders" do
      before do
        allow(IngestFolder).to receive(:permitted_folders).with(user).and_return(nil)
        visit batches_path
      end
      it "should not include a link to create an ingest folder" do
        expect(page).to_not have_link(menu_label, new_ingest_folder_path)
      end
    end
    context "user has permitted ingest folders" do
      before do
        allow(IngestFolder).to receive(:permitted_folders).with(user).and_return(["/base/path/"])
        visit batches_path
      end
      it "should include a link to create an ingest folder" do
        expect(page).to have_link(menu_label, new_ingest_folder_path)
      end
    end
  end
  context "metadata files", :metadata_file => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:menu_label) { I18n.t('dul_hydra.metadata_file.new_menu') }
    let(:metadata_file_creator) { Role.create("Metadata File Creator", ability: "create", model: "MetadataFile") }
    before do
      login_as user
    end
    context "user is not permitted to upload metadata files" do
      before do
        visit batches_path
      end
      it "should not include a link to upload a metadata file" do
        expect(page).to_not have_link(menu_label, new_metadata_file_path)
      end
    end
  end
  context "batches" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    let(:other_user) { FactoryGirl.create(:user) }
    context "pending batches" do
      let(:tab_id) { '#tab_pending_batches' }
      context "user has no pending batches" do
        before do
          login_as other_user
          visit batches_path
        end
        it "should display an appropriate message" do
          within tab_id do
            expect(page).to have_text(I18n.t('batch.web.no_batches', :type => I18n.t('dul_hydra.tabs.pending_batches.label')))
          end
        end
      end
      context "user has some pending batches" do
        before do
          login_as batch.user
          visit batches_path
        end
        it "should list the batch on the pending tab" do
          within tab_id do
            expect(page).to have_link(batch.id, :href => batch_path(batch))
          end
        end
      end
      context "new batch" do
        context "new" do
          before do
            login_as batch.user
            visit batches_path
          end
          it "should not have a link to process the batch" do
            within tab_id do
              expect(page).to_not have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
            end
          end
        end
      end
      context "ready to process batch" do
        context "ready" do
          before do
            batch.status = Ddr::Batch::Batch::STATUS_READY
            batch.save
            login_as batch.user
            visit batches_path
          end
          it "should have a link to process the batch" do
            within tab_id do
              expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
            end
          end
        end
      end
      context "validate action" do
        before { login_as batch.user }
        context "validated and valid" do
          before do
            batch.status = Ddr::Batch::Batch::STATUS_VALIDATED
            batch.save
            visit batches_path
          end
          it "should have a link to process the batch" do
            within tab_id do
              expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
            end
          end
        end
        context "validated and invalid" do
          before do
            batch.status = Ddr::Batch::Batch::STATUS_INVALID
            batch.save
            visit batches_path
          end
          it "should have a link to retry the batch" do
            within tab_id do
              expect(page).to have_link(I18n.t('batch.web.action_names.retry'), :href => procezz_batch_path(batch))
            end
          end
        end
      end
    end
    context "finished batches" do
      let(:tab_id) { '#tab_finished_batches' }
      context "user has no finished batches" do
        before do
          login_as other_user
          visit batches_path
        end
        it "should display an appropriate message" do
          within tab_id do
            expect(page).to have_text(I18n.t('batch.web.no_batches', :type => I18n.t('dul_hydra.tabs.finished_batches.label')))
          end
        end
      end
      context "user has some finished batches" do
        before do
          batch.status = Ddr::Batch::Batch::STATUS_FINISHED
          batch.save
          login_as batch.user
          visit batches_path
        end
        it "should list the batch on the already run tab" do
          within tab_id do
            expect(page).to have_link(batch.id, :href => batch_path(batch))
          end
        end
      end
    end
    context "deleting batches" do
      before { login_as batch.user }
      context "no delete-able batches" do
        [ Ddr::Batch::Batch::STATUS_QUEUED, Ddr::Batch::Batch::STATUS_RUNNING,
          Ddr::Batch::Batch::STATUS_FINISHED, Ddr::Batch::Batch::STATUS_INTERRUPTED,
          Ddr::Batch::Batch::STATUS_RESTARTABLE ].each do |status|
            context "status #{status}" do
              before do
                batch.status = status
                batch.save
                visit batches_path
              end
              it "should not have a link to delete the batch" do
                expect(page).to_not have_link("batch_delete_#{batch.id}")
              end
            end
          end
      end
    end
  end
end
