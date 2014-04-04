module DulHydra
  module HasAttachments
    extend ActiveSupport::Concern

    included do
      has_many :attachments, property: :is_attached_to, class_name: 'Attachment'
    end

  end
end
