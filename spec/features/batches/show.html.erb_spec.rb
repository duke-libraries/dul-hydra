require 'spec_helper'

describe "batches/show.html.erb" do

  context "batch" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    context "batch info" do
      before { login_as batch.user }
      context "new batch" do
        before { visit batch_path(batch) }
        it "should not have a link to process the batch" do
          expect(page).to_not have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
        end
      end
      context "ready to process batch" do
        before do
          batch.status = DulHydra::Batch::Models::Batch::STATUS_READY
          batch.save
          visit batch_path(batch)
        end
        it "should have a link to process the batch" do
          expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
        end
      end
      context "validate action" do
        context "not yet validated" do
          before { visit batch_path(batch) }
          it "should have a link to validate the batch" do
            pending "reworking of separate validate action" do
              expect(page).to have_link(I18n.t('batch.web.action_names.validate'), :href => validate_batch_path(batch))
            end
          end
          it "should return to the index page" do
            pending "reworking of separate validate action" do
              click_link I18n.t('batch.web.action_names.validate')
              expect(page).to have_text("Batch #{batch.id}")
            end
          end
        end
        context "validated" do
          before do
            batch.status = DulHydra::Batch::Models::Batch::STATUS_VALIDATED
            batch.save
            visit batch_path(batch)
          end
          it "should have a link to process the batch" do
            expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
          end
        end
      end          
      context "delete action" do
        context "delete-able" do
          [ nil, DulHydra::Batch::Models::Batch::STATUS_READY, DulHydra::Batch::Models::Batch::STATUS_VALIDATED,
            DulHydra::Batch::Models::Batch::STATUS_INVALID ].each do |status|
            context "status #{status}" do
              before do
                batch.status = status
                batch.save
                visit batch_path(batch)
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
        end
        context "not delete-able" do
          [ DulHydra::Batch::Models::Batch::STATUS_QUEUED, DulHydra::Batch::Models::Batch::STATUS_RUNNING,
            DulHydra::Batch::Models::Batch::STATUS_FINISHED, DulHydra::Batch::Models::Batch::STATUS_INTERRUPTED,
            DulHydra::Batch::Models::Batch::STATUS_RESTARTABLE ].each do |status|
            context "status #{status}" do
              before do
                batch.status = status
                batch.save
                visit batch_path(batch)
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

end
