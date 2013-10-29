class RemoveBatchRunTable < ActiveRecord::Migration
  
  def self.up
    drop_table :batch_runs
  end
  
  def self.down
    create_table "batch_runs" do |t|
      t.integer  "batch_id"
      t.string   "status"
      t.datetime "start"
      t.datetime "stop"
      t.string   "outcome"
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.text     "details"
      t.integer  "failure",              :default => 0
      t.integer  "success",              :default => 0
      t.integer  "total",                :default => 0
      t.string   "version"
      t.string   "logfile_file_name"
      t.string   "logfile_content_type"
      t.integer  "logfile_file_size"
      t.datetime "logfile_updated_at"
    end
  end

end