class IngestFoldersController < ApplicationController

  def new
    puts "Got here"
    @ingest_folder = IngestFolder.new
  end
  
  def create
  end
  
  def show
  end
    
end