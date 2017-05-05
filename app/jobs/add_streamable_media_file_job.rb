class AddStreamableMediaFileJob < ActiveJob::Base

  queue_as :batch

  def perform(args)
    AddStreamableMediaFile.new(args).process
  end

end
