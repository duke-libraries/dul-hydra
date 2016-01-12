require 'spec_helper'
require 'support/shared_examples_for_repository_controllers'

describe TargetsController, type: :controller, targets: true do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  it_behaves_like "a repository object controller" do
    let(:object) { FactoryGirl.create(:target) }
  end

end
