require "tempfile"
require "csv"

email_addrs = ARGV
if email_addrs.empty?
  puts "Email address(es) required"
  exit(false)
end

headers = [
  "PID",
  "COLLECTION TITLE",
  "CREATION DATE",
  "ADMIN SET",
  "OBJECT COUNT",
  "WORKFLOW STATE",
  "TOTAL SIZE",
  "TOTAL SIZE (BYTES)"
]

Tempfile.create(["collection_summary", ".csv"]) do |outfile|
  outfile.close
  CSV.open(outfile, "wb", headers: true, write_headers: true) do |csv|
    csv << headers
    collections = Ddr::Index::Query.new do
      model "Collection"
      fields :id, :title, :object_profile, :admin_set, :workflow_state, :internal_uri
    end
    collections.docs.each do |doc|
      objects = Ddr::Index::Query.new { is_governed_by doc.id }
      content = Ddr::Index::Query.new do
        has_content
        is_governed_by doc.id
        fields :id, :content_size
      end
      total_size = content.docs.map(&:content_size).reduce(0, :+)
      human_size = ActiveSupport::NumberHelper.number_to_human_size(total_size)
      creation_date = doc.object_create_date.strftime('%Y-%m-%d') rescue nil
      csv << [doc.id, doc.title, creation_date, doc.admin_set, objects.count, doc.workflow_state, human_size, total_size]
    end
  end
  mail = ReportMailer.basic(to: email_addrs,
                            subject: "Collection Summary Report",
                            content: File.read(outfile),
                            filename: "collection_summary.csv")
  mail.deliver
end
