RSpec.describe DulHydra do

  describe "configuration defaults" do
    subject { described_class }
    its(:auto_assign_permanent_id) { is_expected.to be false }
    its(:auto_update_permanent_id) { is_expected.to be false }
    its(:fixity_check_limit) { is_expected.to eq(10000) }
    its(:fixity_check_period_in_days) { is_expected.to eq(60) }
    its(:batches_per_page) { is_expected.to eq(10) }
  end

end
