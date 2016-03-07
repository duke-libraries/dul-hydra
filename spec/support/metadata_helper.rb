require 'spec_helper'

def sample_metadata_array
  [ { "title" => "Sample title" },
    { "creator" => "Sample, Example" },
    { "type" => "Image" },
    { "type" => "Still Image" },
    { "spatial" => "Durham County (NC)" },
    { "spatial" => "Durham (NC)" },
    { "date" => "1981-01" },
    { "rights" => "The copyright for these materials is unknown." },
    { "print_number" => "12-345-6" },
    { "series" => "Photographic Materials Series" },
    { "subseries" => "Local Court House" }
  ]
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
          <duke:subseries>Local Court House</duke:subseries>
        </xmlData>
      </mdWrap>
    </dmdSec>
    <amdSec ID="abcd_efghi01003-amd">
      <sourceMD>
        <mdWrap>
          <xmlData>
            <dcterms:source>abcdcollection/123456abcdef654321</dcterms:source>
          </xmlData>
        </mdWrap>
      </sourceMD>
    </amdSec>
  <fileSec>
    <fileGrp ID="collectiona_efghi01003-images" TYPE="Images">
      <file ID="efghi010030010"/>
      <file ID="efghi010030020"/>
      <file ID="efghi010030030"/>
    </fileGrp>
    <fileGrp ID="collectiona_efghi01003-documents" TYPE="Documents">
      <file ID="efghi01003"/>
    </fileGrp>
  </fileSec>
  <structMap>
    <div ID="collectiona_efghi01003-images" TYPE="Images">
      <div ID="efghi010030010" ORDER="1">
        <fptr fileID="efghi010030010"/>
      </div>
      <div ID="efghi010030020" ORDER="2">
        <fptr fileID="efghi010030020"/>
      </div>
      <div ID="efghi010030030" ORDER="3">
        <fptr fileID="efghi010030030"/>
      </div>
    </div>
    <div ID="collectiona_efghi01003-documents" TYPE="Documents">
      <div ID="efghi01003" ORDER="1">
        <fptr fileID="efghi01003"/>
      </div>
    </div>
  </structMap>
  </mets>
  EOS
end

def sample_xml_struct_metadata
  xml = <<-EOS
    <?xml version="1.0"?>
    <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
      <structMap TYPE="default">
    <div ID="collectiona_efghi01003-images" TYPE="Images">
      <div ID="efghi010030010" ORDER="1">
        <fptr CONTENTIDS="test-19"/>
      </div>
      <div ID="efghi010030020" ORDER="2">
        <fptr CONTENTIDS="test-20"/>
      </div>
      <div ID="efghi010030030" ORDER="3">
        <fptr CONTENTIDS="test-21"/>
      </div>
    </div>
    <div ID="collectiona_efghi01003-documents" TYPE="Documents">
      <div ID="efghi01003" ORDER="1">
        <fptr CONTENTIDS="test-25"/>
      </div>
    </div>
      </structMap>
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

def sample_mets_xml_with_missing_type_attr
  xml = <<-EOS
  <mets xmlns:duke="http://library.duke.edu/metadata/terms" xmlns:dcterms="http://purl.org/dc/terms" xmlns:xlink="http://www.w3.org/TR/xlink/" ID="abcd_efghi01003">
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

def sample_mets_xml_with_ead_id_no_aspace_id
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
    <amdSec ID="abcd_efghi01003-amd">
      <sourceMD>
        <mdWrap>
          <xmlData>
            <dcterms:source>abcdcollection</dcterms:source>
          </xmlData>
        </mdWrap>
      </sourceMD>
    </amdSec>
  </mets>
  EOS
end

def sample_mets_xml_with_aspace_id_no_ead_id
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
    <amdSec ID="abcd_efghi01003-amd">
      <sourceMD>
        <mdWrap>
          <xmlData>
            <dcterms:source>/123456abcdef654321</dcterms:source>
          </xmlData>
        </mdWrap>
      </sourceMD>
    </amdSec>
  </mets>
  EOS
end

def sample_mets_xml_with_missing_fptr_fileid_attr
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
        </xmlData>
      </mdWrap>
    </dmdSec>
  <fileSec>
    <fileGrp ID="collectiona_efghi01003-images" TYPE="Images">
      <file ID="efghi010030010"/>
      <file ID="efghi010030020"/>
      <file ID="efghi010030030"/>
    </fileGrp>
    <fileGrp ID="collectiona_efghi01003-documents" TYPE="Documents">
      <file ID="efghi01003"/>
    </fileGrp>
  </fileSec>
  <structMap>
    <div ID="collectiona_efghi01003-images" TYPE="Images">
      <div ID="efghi010030010" ORDER="1">
        <fptr fileID="efghi010030010"/>
      </div>
      <div ID="efghi010030020" ORDER="2">
        <fptr/>
      </div>
      <div ID="efghi010030030" ORDER="3">
        <fptr fileID="efghi010030030"/>
      </div>
    </div>
    <div ID="collectiona_efghi01003-documents" TYPE="Documents">
      <div ID="efghi01003" ORDER="1">
        <fptr fileID="efghi01003"/>
      </div>
    </div>
  </structMap>
  </mets>
  EOS
end
