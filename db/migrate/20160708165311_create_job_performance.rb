class CreateJobPerformance < ActiveRecord::Migration
  def change
    create_table :job_performances do |t|
      t.string   :job, index: true
      t.string   :queue, index: true
      t.string   :args
      t.datetime :started, index: true
      t.datetime :finished, index: true
      t.integer  :duration, index: true
      t.string   :exception
      t.boolean  :success, index: true
    end
  end
end
