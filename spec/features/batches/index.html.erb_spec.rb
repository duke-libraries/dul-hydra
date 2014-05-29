require 'spec_helper'

describe "batches/index.html.erb" do
  context "ingest folders" do
    let(:user) { FactoryGirl.create(:user) }
    let(:menu_label) { I18n.t('dul_hydra.ingest_folder.new_menu') }
    before { login_as user }
    after do
      user.destroy
      Warden.test_reset!
    end
    context "user has no permitted ingest folders" do
      before do
        IngestFolder.stub(:permitted_folders).with(user).and_return(nil)
        visit batches_path
      end
      it "should not include a link to create an ingest folder" do
        expect(page).to_not have_link(menu_label, new_ingest_folder_path)
      end
    end
    context "user has permitted ingest folders" do
      before do
        IngestFolder.stub(:permitted_folders).with(user).and_return(["/base/path/"])
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
    after do
      user.destroy
      Warden.test_reset!
    end
    context "user is not permitted to upload metadata files" do
      before do
        visit batches_path
      end
      it "should not include a link to upload a metadata file" do
        expect(page).to_not have_link(menu_label, new_metadata_file_path)
      end
    end
    context "user is permitted to upload metadata files" do
      before do
        user.roles << Role.create(name: "Metadata File Uploader", ability: "create", model: "MetadataFile")
        user.save!
      end
      after { Role.destroy_all }
      it "should include a link to upload a metadata file" do
        visit batches_path
        expect(page).to have_link(menu_label, new_metadata_file_path)
      end
    end
  end
  context "batches" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    let(:other_user) { FactoryGirl.create(:user) }
    after do
      other_user.delete
      batch.user.delete
      batch.destroy
      Warden.test_reset!
    end
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
        after { batch.destroy }
        it "should list the batch on the pending tab" do
          within tab_id do
            expect(page).to have_link(batch.id, :href => batch_path(batch))
          end
        end
      end
      context "validate action" do
        before { login_as batch.user }
        context "not yet validated" do
          before { visit batches_path }
          it "should have a link to validate the batch" do
            pending "reworking of separate validate action" do
              within tab_id do
                expect(page).to have_link(I18n.t('batch.web.action_names.validate'), :href => validate_batch_path(batch))
              end
            end
          end
          it "should return to the index page" do
            pending "reworking of separate validate action" do
              within tab_id do
                click_link I18n.t('batch.web.action_names.validate')
                expect(current_path).to eq(batches_path)
              end
            end
          end
        end
        context "validated" do
          before do
            batch.status = DulHydra::Batch::Models::Batch::STATUS_VALIDATED
            batch.save
            visit batches_path
          end
          it "should have a link to process the batch" do
            within tab_id do
              expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
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
          batch.status = DulHydra::Batch::Models::Batch::STATUS_FINISHED
          batch.save
          login_as batch.user
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
    context "deleting batches" do
      before { login_as batch.user }
      context "delete-able batches" do
        [ nil, DulHydra::Batch::Models::Batch::STATUS_VALIDATED ].each do |status|
          before do
            batch.status = status
            batch.save
            visit batches_path
          end
          it "should have a link to delete the batch" do
            expect(page).to have_link("batch_delete_#{batch.id}")
            click_link "batch_delete_#{batch.id}"
            expect(current_path).to eql(batches_path)
            expect(page).to have_content(I18n.t("batch.web.batch_deleted", :id => batch.id))
            expect(page).to_not have_link(batch.id, :href => batch_path(batch))
          end
        end
      end
      context "no delete-able batches" do
        [ DulHydra::Batch::Models::Batch::STATUS_QUEUED, DulHydra::Batch::Models::Batch::STATUS_RUNNING,
          DulHydra::Batch::Models::Batch::STATUS_FINISHED, DulHydra::Batch::Models::Batch::STATUS_INTERRUPTED,
          DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE ].each do |status|
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
