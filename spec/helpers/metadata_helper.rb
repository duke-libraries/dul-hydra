require 'spec_helper'

def sample_metadata_triples(subject_string="_:test")
  triples = <<-EOS
#{subject_string} <http://purl.org/dc/terms/title> "Sample title" .
#{subject_string} <http://purl.org/dc/terms/creator> "Sample, Example" .
#{subject_string} <http://purl.org/dc/terms/type> "Image" .
#{subject_string} <http://purl.org/dc/terms/type> "Still Image" .
#{subject_string} <http://purl.org/dc/terms/spatial> "Durham County (NC)" .
#{subject_string} <http://purl.org/dc/terms/spatial> "Durham (NC)" .
#{subject_string} <http://purl.org/dc/terms/date> "1981-01" .
#{subject_string} <http://purl.org/dc/terms/rights> "The copyright for these materials is unknown." .
#{subject_string} <http://library.duke.edu/metadata/terms/print_number> "12-345-6" .
#{subject_string} <http://library.duke.edu/metadata/terms/series> "Photographic Materials Series" .
#{subject_string} <http://library.duke.edu/metadata/terms/subseries> "Local Court House" .
EOS
end

def sample_mets_xml
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <dcterms:title>Sample title</dcterms:title>
          <dcterms:creator>Sample, Example</dcterms:creator>
          <dcterms:type>Image</dcterms:type>
          <dcterms:type>Still Image</dcterms:type>
          <dcterms:spatial>Durham County (NC)</dcterms:spatial>
          <dcterms:spatial>Durham (NC)</dcterms:spatial>
          <dcterms:date>1981-01</dcterms:date>
          <dcterms:rights>The copyright for these materials is unknown.</dcterms:rights>
          <duke:print_number>12-345-6</duke:print_number>
          <duke:series>Photographic Materials Series</duke:series>
          <duke:subseries>Local Court House</duke:series>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end

def sample_mets_with_element_attribute
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <duke:dcmitype>Still Image</duke:dcmitype>
          <dcterms:extent unit="inches">12.5 in x 9.5 in</dcterms:extent>
          <dcterms:title>Document Title</dcterms:title>
          <dcterms:abstract>Document abstract.</dcterms:abstract>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end

def sample_mets_with_unknown_duketerm
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <duke:unknown>Still Image</duke:unknown>
          <dcterms:extent>12.5 in x 9.5 in</dcterms:extent>
          <dcterms:title>Document Title</dcterms:title>
          <dcterms:abstract>Document abstract.</dcterms:abstract>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end

def sample_mets_with_no_namespace_element
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <duke:dcmitype>Still Image</duke:dcmitype>
          <dcterms:extent>12.5 in x 9.5 in</dcterms:extent>
          <dcterms:title>Document Title</dcterms:title>
          <abstract>Document abstract.<abstract>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end

def sample_mets_with_unknown_namespace
  xml = <<-EOS
  <mets xmlns:special="http://special.org/" xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <duke:dcmitype>Still Image</duke:dcmitype>
          <special:extent>12.5 in x 9.5 in</special:extent>
          <dcterms:title>Document Title</dcterms:title>
          <dcterms:abstract>Document abstract.<dcterms:abstract>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end

def sample_mets_with_invalid_namespace_href
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/duketerms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003" TYPE="Resource:slideshow">
    <metsHdr>
      <agent ID="library" ROLE="CUSTODIAN">
        <name>Library</name>
      </agent>
    </metsHdr>
    <dmdSec ID="abcd_efghi01003">
      <mdWrap>
        <xmlData>
          <duke:dcmitype>Still Image</duke:dcmitype>
          <dcterms:extent>12.5 in x 9.5 in</dcterms:extent>
          <dcterms:title>Document Title</dcterms:title>
          <dcterms:abstract>Document abstract.</dcterms:abstract>
        </xmlData>
      </mdWrap>
    </dmdSec>
  </mets>
  EOS
end
