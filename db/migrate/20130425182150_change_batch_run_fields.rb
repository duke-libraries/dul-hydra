class ChangeBatchRunFields < ActiveRecord::Migration
  def up
    add_column :batch_runs, :details, :text
    add_column :batch_runs, :failure, :integer, :default => 0
    add_column :batch_runs, :success, :integer, :default => 0
    add_column :batch_runs, :total, :integer, :default => 0
    add_column :batch_runs, :version, :string
    remove_column :batch_runs, :outcome_details
  end

  def down
    add_column :batch_runs, :outcome_details, :text
    remove_column :batch_runs, :version
    remove_column :batch_runs, :total
    remove_column :batch_runs, :success
    remove_column :batch_runs, :failure
    remove_column :batch_runs, :details
  end
end
