module ArchivesSpace
  class CreateDigitalObjectsJob < ActiveJob::Base

    queue_as :aspace

    def perform(collection_id, options)
      csv = ArchivesSpace::ExportDigitalObjectInfo.call(collection_id).csv
      output = ArchivesSpace::CreateDigitalObjects.call(csv, options.slice(:user, :publish))
      subject = "REPORT: Create Digital Objects for #{collection_id}"
      message = "The report is attached."
      ::ReportMailer.basic(
        subject:  subject,
        content:  output,
        filename: options[:filename],
        to:       options[:notify],
        message:  message
      ).deliver_now
    end

  end
end
