require 'spec_helper'
require "#{Rails.root}/app/helpers/metadata_files_helper"

include MetadataFilesHelper

shared_examples "metadata file show page" do
  it "should display information about the metadata file" do
    within form_data_id do
      expect(page.find('tr:nth-child(2)')).to have_content(metadata_file.metadata_file_name)
      expect(page.find('tr:nth-child(2)')).to have_content(MetadataFilesHelper.metadata_file_profile_name(metadata_file.profile))
      expect(page.find('tr:nth-child(2)')).to have_content(csv_table.length)
    end
    within headers_id do
      headers_text.each_with_index do |header_row, idx|
        header_row.each do |header_text|
          expect(page.find("tr:nth-child(#{idx + 1})")).to have_content(header_text)
        end
      end
    end
    within rows_id do
      rows_text.each_with_index do |row, idx|
        row.each do |row_text|
          expect(page.find("tr:nth-child(#{idx + 1})")).to have_content(row_text.truncate(30))
        end
      end
    end
  end  
end

describe "metadata_files/show.html.erb", :type => :feature, :metadata_file => true do
  
  let(:csv_table) { CSV.read(metadata_file.metadata.path, metadata_file.effective_options[:csv]) }
  let(:form_data_id) { '#form_data' }
  let(:headers_id) { '#headers' }
  let(:rows_id) { '#rows' }
  let(:rows_text) {
    [ [ 'test12345', 'Updated Title', 'This is some description; this is "some more" description.', 'Alpha; Beta; Gamma', 'Delta; Epsilon', '2010-01-22' ] ]
  }
  
  before do
    login_as metadata_file.user
    visit(metadata_file_path(metadata_file))
  end
  
  context "factory version" do
    let(:metadata_file) { FactoryGirl.create(:metadata_file_descmd_csv) }
    let(:headers_text) {
      [ [ 'identifier', 'title', 'description', 'subject', 'subject', 'dateSubmitted', 'arranger' ],
        [ '', '', '', 'multi', 'multi', '', ''] ]
    }
    it_behaves_like "metadata file show page"
  end
  
  context "tab-delimited mapped schema" do
    let(:metadata_file) { FactoryGirl.create(:metadata_file_mapped_tab) }
    let(:headers_text) {
      [ [ 'Identifier-LocalID', 'Title', 'Description', 'Subject-Topic', 'Subject-Keyword', 'Submission-Date', 'Arranger' ],
        [ '', '', '', 'multi', 'multi', '', ''],
        [ 'identifier', 'title', 'description', 'subject', 'subject', 'dateSubmitted', 'arranger' ] ]
    }
    it_behaves_like "metadata file show page"    
  end
  
end
