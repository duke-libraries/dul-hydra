require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe 'components/show.html.erb' do
  it_behaves_like "a DulHydra object show view" do
    subject { page }
    let(:obj) { FactoryGirl.create(:component_part_of_item_has_apo) }
    before { visit component_path(obj) }
    after do
      obj.item.delete
      obj.admin_policy.delete
      obj.reload
      obj.delete
    end
  end
end
