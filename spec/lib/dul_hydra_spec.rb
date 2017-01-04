RSpec.describe DulHydra do

  describe "configuration defaults" do
    subject { described_class }
    its(:fixity_check_limit) { is_expected.to eq(10000) }
    its(:fixity_check_period_in_days) { is_expected.to eq(60) }
    its(:batches_per_page) { is_expected.to eq(10) }
  end

end
