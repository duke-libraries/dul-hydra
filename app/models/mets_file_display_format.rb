class METSFileDisplayFormat

  class << self
    attr_accessor :display_format_translations
  end

  def self.get(mets_file, display_formats)
    return if mets_file.root_type_attr.blank?
    type_attr = mets_file.root_type_attr.split(':').last.downcase
    display_formats[type_attr] || type_attr
  end

end
