require 'spec_helper'
require 'helpers/user_helper'

describe "batches/index.html.erb" do
  let(:user) { FactoryGirl.create(:user) }
  context "logged in user" do
    before do
      login user
    end
    after { user.delete }
    context "ingest folders" do
      context "user has no permitted ingest folders" do
        before do
          IngestFolder.stub(:permitted_folders).with(user).and_return(nil)
          visit batches_path
        end
        it "should not include a link to create an ingest folder" do
          expect(page).to_not have_button(I18n.t('batch.ingest_folder.create'))
        end
      end
      context "user has permitted ingest folders" do
        before do
          IngestFolder.stub(:permitted_folders).with(user).and_return(["/base/path/"])
          visit batches_path
        end
        it "should include a link to create an ingest folder" do
          expect(page).to have_button(I18n.t('batch.ingest_folder.create'))
        end
      end
    end
    context "batches" do
      let(:batch) { DulHydra::Batch::Models::Batch.new }
      context "pending batches" do
        let(:tab_id) { '#tab_pending_batches' }
        context "user has no pending batches" do
          before { visit batches_path }
          it "should display an appropriate message" do
            within tab_id do
              expect(page).to have_text(I18n.t('batch.web.no_batches', :type => I18n.t('dul_hydra.tabs.pending_batches.label')))
            end
          end
        end
        context "user has some pending batches" do
          before do
            batch.user = user
            batch.save
            visit batches_path
          end
          after { batch.destroy }
          it "should list the batch on the pending tab" do
            within tab_id do
              expect(page).to have_link(batch.id, :href => batch_path(batch))
            end
          end
        end
      end
      context "finished batches" do
        let(:tab_id) { '#tab_finished_batches' }
        context "user has no finished batches" do
          before { visit batches_path }
          it "should display an appropriate message" do
            within tab_id do
              expect(page).to have_text(I18n.t('batch.web.no_batches', :type => I18n.t('dul_hydra.tabs.finished_batches.label')))
            end
          end        
        end
        context "user has some finished batches" do
          before do
            batch.user = user
            batch.status = DulHydra::Batch::Models::Batch::STATUS_FINISHED
            batch.save
            visit batches_path
          end
          after { batch.destroy }
          it "should list the batch on the already run tab" do
            within tab_id do
              expect(page).to have_link(batch.id, :href => batch_path(batch))
            end
          end
        end
      end
    end
  end
end