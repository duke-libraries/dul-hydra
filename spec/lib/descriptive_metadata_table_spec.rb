require 'spec_helper'

module DulHydra
  describe DescriptiveMetadataTable do

    let(:objects) { FactoryGirl.create_list(:test_model, 3) }
    it "should have headers" do
      expect(described_class.new(objects).headers).to match_array([:pid, :title, :identifier])
    end
    it "should have rows with values" do
      dm_table = described_class.new(objects)
      objects.each_with_index do |obj, i|
        dm_table.headers.each do |h|
          value = obj.send(h)
          value = value.first if value.is_a? Array
          expect(dm_table[i][h]).to eq(value)
        end
      end
    end
    context "repeated columns" do
      before do
        objects[0].identifier = ["foo", "bar", "baz"]
        objects[0].save
        objects[1].identifier = ["spam", "eggs"]
        objects[1].save
      end
      it "should have repeated headers" do
        expect(described_class.new(objects).headers).to match_array([:pid, :title, :identifier, :identifier, :identifier])
      end
      it "should have the right values" do
        dm_table = described_class.new(objects)
        first_identifier_index = dm_table.headers.index(:identifier)
        identifier_indices = first_identifier_index .. first_identifier_index+2
        objects.each_with_index do |obj, i|
          expect(dm_table[i][:pid]).to eq(obj.id)
          expect(dm_table[i][:title]).to eq(obj.title.first)
          j = 0
          while idx = dm_table[i].index(:identifier, first_identifier_index + j)
            expect(dm_table[i][idx]).to eq(obj.identifier[j])
            j += 1
          end
        end
      end
    end

  end
end
