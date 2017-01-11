shared_examples "an abstract job" do

  describe ".queued_object_ids" do
    before do
      @queued = [
        {"class"=>described_class.name, "args"=>["test:1"]},
        {"class"=>"OtherJob", "args"=>["test:2"]},
        {"class"=>described_class.name, "args"=>["test:3"]},
      ]

      allow(Resque).to receive(:size) { @queued.size }
      allow(Resque).to receive(:peek) { @queued }
    end
    it "returns the list of object_ids for queued jobs of this type" do
      expect(described_class.queued_object_ids)
        .to contain_exactly("test:1", "test:3")
    end
  end

end
