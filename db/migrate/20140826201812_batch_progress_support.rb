class BatchProgressSupport < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.datetime :processing_step_start
    end
    change_table :batch_objects do |t|
      t.index :verified
    end
  end
end
