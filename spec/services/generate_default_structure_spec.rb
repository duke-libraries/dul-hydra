require 'spec_helper'

RSpec.describe GenerateDefaultStructure, type: :service do

  let(:repo_id) { 'test:1' }
  let(:repo_obj) { Item.new(pid: repo_id) }
  let(:example_default_structure) { simple_structure_document }

  before { allow(ActiveFedora::Base).to receive(:find).with(repo_id) { repo_obj } }

  subject { GenerateDefaultStructure.new(repo_id) }

  context "object cannot have structure" do
    before { allow(repo_obj).to receive(:can_have_struct_metadata?) { false } }
    it "raises an error" do
      expect { subject.process }.to raise_error(ArgumentError, "#{repo_id} cannot have structural metadata.")
    end
  end

  context "object can have structure" do
    before { allow(repo_obj).to receive(:can_have_struct_metadata?) { true } }
    context "object has no existing structure" do
      before { allow(repo_obj).to receive(:has_struct_metadata?) { false } }
      it "generates and sets default structure" do
        expect(repo_obj).to receive(:default_structure) { example_default_structure }
        expect(repo_obj).to receive(:save!)
        subject.process
      end
    end
    context "object has existing structure" do
      before { allow(repo_obj).to receive(:has_struct_metadata?) { true } }
      context "existing structure is repository maintained" do
        before { allow(repo_obj).to receive_message_chain(:structure, :repository_maintained?) { true } }
        it "generates and sets default structure" do
          expect(repo_obj).to receive(:default_structure) { example_default_structure }
          expect(repo_obj).to receive(:save!)
          subject.process
        end
      end
      context "existing structure is not repository maintained" do
        before { allow(repo_obj).to receive_message_chain(:structure, :repository_maintained?) { false } }
        context "overwrite provided" do
          before { allow(subject).to receive(:overwrite_provided) { true }}
          it "generates and sets default structure" do
            expect(repo_obj).to receive(:default_structure) { example_default_structure }
            expect(repo_obj).to receive(:save!)
            subject.process
          end
        end
        context "do not overwrite provided" do
          before { allow(subject).to receive(:overwrite_provided) { false } }
          it "raises an error" do
            expect { subject.process }.to raise_error(ArgumentError,
                                  "#{repo_id} has externally provided structural metadata; override option required.")
          end
        end
      end
    end

  end
end
