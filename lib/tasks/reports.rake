#
# Report tasks
#
require "tempfile"

namespace :dul_hydra do
  namespace :reports do
    desc "Collection summary report"
    task :collection_summary, [:email] => :environment do |t, args|
      unless args[:email]
        puts "Email address is required."
        exit(false)
      end
      report_path = File.join(Rails.root, "reports", "collection_summary.rb")
      pid = spawn("bundle exec rails runner #{report_path} #{args[:email]}")
      Process.detach(pid)
      puts "Report started (PID: #{pid})"
    end
  end
end
