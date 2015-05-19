class CreateMintedIds < ActiveRecord::Migration
  def change
    create_table :minted_ids do |t|
      t.string :minted_id
      t.string :referent

      t.timestamps
    end
    add_index :minted_ids, :minted_id, unique: true
    add_index :minted_ids, :referent
  end
end
