require 'spec_helper'
require 'helpers/user_helper'

describe "batches/show.html.erb" do

  context "batch" do
    let(:batch) { FactoryGirl.create(:batch_with_basic_ingest_batch_objects) }
    after do
      batch.user.delete
      batch.destroy
    end
    context "batch info" do
      context "validate action" do
        before { login batch.user }
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
    end
  end

end