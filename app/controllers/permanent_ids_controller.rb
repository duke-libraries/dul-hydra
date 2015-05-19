class PermanentIdsController < ApplicationController

  def show
    redirect_to resolve_id
  end

  protected

  def resolve_id
    permanent_id = params.require(:permanent_id)
    results = ActiveFedora::Base.find(Ddr::IndexFields::PERMANENT_ID => permanent_id)
    if results.empty?
      raise ActiveFedora::ObjectNotFoundError, "Object having permanent_id \"#{permanent_id}\" was not found."
    end
    results.first
  end

end
