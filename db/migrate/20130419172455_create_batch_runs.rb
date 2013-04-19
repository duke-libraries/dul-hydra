class CreateBatchRuns < ActiveRecord::Migration
  def change
    create_table :batch_runs do |t|
      t.references :batch
      t.string :status
      t.datetime :start
      t.datetime :stop
      t.string :outcome
      t.text :outcome_details

      t.timestamps
    end
  end
end
