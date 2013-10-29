class AddBatchRunColumnsToBatch < ActiveRecord::Migration
  
  def self.up
    add_column :batches, :status, :string
    add_column :batches, :start, :datetime
    add_column :batches, :stop, :datetime
    add_column :batches, :outcome, :string
    add_column :batches, :details, :text
    add_column :batches, :failure, :integer, :default => 0
    add_column :batches, :success, :integer, :default => 0
    add_column :batches, :total, :integer, :default => 0
    add_column :batches, :version, :string
    add_attachment :batches, :logfile
  end

  def self.down
    drop_attached_file :batches, :logfile
    remove_column :batches, :version
    remove_column :batches, :total
    remove_column :batches, :success
    remove_column :batches, :failure
    remove_column :batches, :details
    remove_column :batches, :outcome
    remove_column :batches, :stop
    remove_column :batches, :start
    remove_column :batches, :status
  end  
  
end
