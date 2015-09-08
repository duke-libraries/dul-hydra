require 'spec_helper'

describe "batches/show.html.erb", :type => :feature do

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
          batch.status = Ddr::Batch::Batch::STATUS_READY
          batch.save
          visit batch_path(batch)
        end
        it "should have a link to process the batch" do
          expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
        end
      end
      context "validate action" do
        context "validated and valid" do
          before do
            batch.status = Ddr::Batch::Batch::STATUS_VALIDATED
            batch.save
            visit batch_path(batch)
          end
          it "should have a link to process the batch" do
            expect(page).to have_link(I18n.t('batch.web.action_names.procezz'), :href => procezz_batch_path(batch))
          end
        end
        context "validated and invalid" do
          before do
            batch.status = Ddr::Batch::Batch::STATUS_INVALID
            batch.save
            visit batch_path(batch)
          end
          it "should have a link to process the batch" do
            expect(page).to have_link(I18n.t('batch.web.action_names.retry'), :href => procezz_batch_path(batch))
          end
        end
      end
      context "delete action" do
        context "not delete-able" do
          [ Ddr::Batch::Batch::STATUS_QUEUED, Ddr::Batch::Batch::STATUS_RUNNING,
            Ddr::Batch::Batch::STATUS_VALIDATING, Ddr::Batch::Batch::STATUS_PROCESSING,
            Ddr::Batch::Batch::STATUS_FINISHED, Ddr::Batch::Batch::STATUS_INTERRUPTED,
            Ddr::Batch::Batch::STATUS_RESTARTABLE ].each do |status|
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
