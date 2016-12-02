# This migration comes from ddr_batch (originally 20161116142512)
class CreateBatchObjectMessages < ActiveRecord::Migration
  def change
    unless table_exists?(:batch_object_messages)
      create_table :batch_object_messages do |t|
        t.integer :batch_object_id
        t.integer :level,   default: Logger::DEBUG
        t.text    :message, limit: 65535

        t.timestamps
      end
    end
  end
end
