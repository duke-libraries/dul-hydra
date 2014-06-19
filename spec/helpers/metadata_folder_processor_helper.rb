require 'spec_helper'

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

def sample_descriptive_metadata_xml
  xml = <<-EOS
    <dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:duke="http://library.duke.edu/metadata/terms">
      <dcterms:identifier>efghi01003</dcterms:identifier>
      <duke:dcmitype>Still Image</duke:dcmitype>
      <dcterms:extent>12.5 in x 9.5 in</dcterms:extent>
      <dcterms:title>Document Title</dcterms:title>
      <dcterms:abstract>Document abstract.</dcterms:abstract>
    </dc>
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
