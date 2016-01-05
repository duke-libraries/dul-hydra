class CreateMetsFolder < ActiveRecord::Migration
  def change
    create_table :mets_folders do |t|
      t.references :user
      t.string :base_path
      t.string :sub_path
      t.string :collection_id

      t.timestamps
    end
  end
end
