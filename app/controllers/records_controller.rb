class RecordsController < ApplicationController

  include RecordsControllerBehavior
  include Blacklight::Base
  
  before_filter :load_document, only: [:new, :edit]

  layout 'objects'

  protected 

  def load_document
    @document = get_solr_response_for_doc_id[1]
  end

  def redirect_after_create
    object_path @record
  end

  def redirect_after_update
    object_path @record
  end

end
