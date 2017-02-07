require 'spec_helper'

RSpec.describe SetDefaultStructuresAfterSuccessfulBatchIngest, type: :service, batch: true do

  let(:batch) { Ddr::Batch::Batch.create }

  context 'ingest objects' do
    let(:repo_id) { 'test:7' }
    let(:batch_object) { Ddr::Batch::IngestBatchObject.create(pid: repo_id) }
    let(:repo_object) { ActiveFedora::Base.new(pid: repo_id) }
    before do
      batch.batch_objects << batch_object
      allow(ActiveFedora::Base).to receive(:find).with(repo_id) { repo_object }
      allow(repo_object).to receive(:parent) { nil }
    end
    context 'can have structural metadata' do
      before do
        allow(repo_object).to receive(:can_have_struct_metadata?) { true }
      end
      context 'existing structural metadata' do
        before do
          allow(repo_object).to receive(:has_struct_metadata?) { true }
        end
        it 'should not enqueue GenerateDefaultStructureJob' do
          expect(Resque).to_not receive(:enqueue).with(GenerateDefaultStructureJob, repo_id)
          ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
        end
      end
      context 'no existing structural metadata' do
        before do
          allow(repo_object).to receive(:has_struct_metadata?) { false }
        end
        it 'should enqueue GenerateDefaultStructureJob once for object' do
          expect(Resque).to receive(:enqueue).with(GenerateDefaultStructureJob, repo_id).once
          ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
        end
      end
    end
    context 'cannot have structural metadata' do
      before do
        allow(repo_object).to receive(:can_have_struct_metadata?) { false }
      end
      it 'should not enqueue GenerateDefaultStructureJob' do
        expect(Resque).to_not receive(:enqueue).with(GenerateDefaultStructureJob, repo_id)
        ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
      end
    end
    context 'parent objects' do
      let(:parent_repo_id) { 'test:4' }
      let(:parent_repo_object) { ActiveFedora::Base.new(pid: parent_repo_id) }
      before do
        allow(ActiveFedora::Base).to receive(:find).with(parent_repo_id) { parent_repo_object }
        allow(repo_object).to receive(:parent) { parent_repo_object }
        allow(parent_repo_object).to receive(:parent) { nil }
        allow(parent_repo_object).to receive(:can_have_struct_metadata?) { true }
      end
      context 'included in batch' do
        let(:parent_batch_object) { Ddr::Batch::IngestBatchObject.create(pid: parent_repo_id) }
        before do
          batch.batch_objects << parent_batch_object
          allow(parent_repo_object).to receive(:has_struct_metadata?) { false }
        end
        it 'should enqueue GenerateDefaultStructureJob for the parent only once' do
          expect(Resque).to receive(:enqueue).with(GenerateDefaultStructureJob, parent_repo_id).once
          ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
        end
      end
      context 'not included in batch' do
        context 'parent has no existing structural metadata' do
          before do
            allow(parent_repo_object).to receive(:has_struct_metadata?) { false }
          end
          it 'should enqueue GenerateDefaultStructureJob for the parent only once' do
            expect(Resque).to receive(:enqueue).with(GenerateDefaultStructureJob, parent_repo_id).once
            ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
          end
        end
        context 'parent has existing structural metadata' do
          before do
            allow(parent_repo_object).to receive(:has_struct_metadata?) { true }
          end
          context 'repository maintained' do
            before do
              allow(parent_repo_object).to receive_message_chain(:structure, :repository_maintained?) { true }
            end
            it 'should enqueue GenerateDefaultStructureJob for the parent only once' do
              expect(Resque).to receive(:enqueue).with(GenerateDefaultStructureJob, parent_repo_id).once
              ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
            end
          end
          context 'externally provided' do
            before do
              allow(parent_repo_object).to receive_message_chain(:structure, :repository_maintained?) { false }
            end
            it 'should not enqueue GenerateDefaultStructureJob for the parent' do
              expect(Resque).to_not receive(:enqueue).with(GenerateDefaultStructureJob, repo_id)
              ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
            end
          end
        end
      end
    end
  end

  context 'update objects' do
    let(:batch_object) { Ddr::Batch::UpdateBatchObject.create }
    before do
      batch.batch_objects << batch_object
    end
    it 'should not enqueue GenerateDefaultStructureJob' do
      expect(Resque).to_not receive(:enqueue).with(GenerateDefaultStructureJob, instance_of(String))
      ActiveSupport::Notifications.instrument('success.batch.batch.ddr', batch_id: batch.id)
    end
  end

end
