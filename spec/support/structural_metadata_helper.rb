require 'spec_helper'

def simple_structure_document
  Nokogiri::XML(simple_structure_xml) do |config|
    config.noblanks
  end
end

def simple_structure_xml
  <<-eos
    <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
      <metsHdr>
        <agent ROLE="CREATOR">
          <name>#{Ddr::Models::Structures::Agent::NAME_REPOSITORY_DEFAULT}</name>
        </agent>
      </metsHdr>
      <structMap TYPE="default">
        <div ORDER="1">
          <mptr LOCTYPE="ARK" xlink:href="ark:/99999/fk4ab3" />
        </div>
        <div ORDER="2">
          <mptr LOCTYPE="ARK" xlink:href="ark:/99999/fk4cd9" />
        </div>
        <div ORDER="3">
          <mptr LOCTYPE="ARK" xlink:href="ark:/99999/fk4ef1" />
        </div>
      </structMap>
    </mets>
  eos
end
