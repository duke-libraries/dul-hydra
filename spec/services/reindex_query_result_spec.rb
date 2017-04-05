RSpec.describe ReindexQueryResult do

  let(:query) { Ddr::Index::Query.new }

  specify {
    allow(query).to receive(:each_id)
                     .and_yield("test:1")
                     .and_yield("test:2")
                     .and_yield("test:3")
    expect(Resque).to receive(:enqueue).with(UpdateIndexJob, "test:1")
    expect(Resque).to receive(:enqueue).with(UpdateIndexJob, "test:2")
    expect(Resque).to receive(:enqueue).with(UpdateIndexJob, "test:3")
    described_class.call(query)
  }

end
