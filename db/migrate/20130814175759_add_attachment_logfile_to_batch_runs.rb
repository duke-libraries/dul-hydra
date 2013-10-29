class AddAttachmentLogfileToBatchRuns < ActiveRecord::Migration
  def self.up
    change_table :batch_runs do |t|
      t.attachment :logfile
    end
  end

  def self.down
    drop_attached_file :batch_runs, :logfile
  end
end
