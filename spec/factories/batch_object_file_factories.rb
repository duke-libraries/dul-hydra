FactoryGirl.define do
  factory :batch_object_file, :class => Ddr::Batch::BatchObjectFile do

    factory :batch_object_add_file do
      operation Ddr::Batch::BatchObjectFile::OPERATION_ADD

      factory :batch_object_add_extracted_text_file_bytes do
        name Ddr::Models::File::EXTRACTED_TEXT
        payload 'abcdefghi'
        payload_type Ddr::Batch::BatchObjectFile::PAYLOAD_TYPE_BYTES
      end

      factory :batch_object_add_extracted_text_file_file do
        name Ddr::Models::File::EXTRACTED_TEXT
        payload File.join(Ddr::Batch::Engine.root, "spec", "fixtures", "ext_text.txt")
        payload_type Ddr::Batch::BatchObjectFile::PAYLOAD_TYPE_FILENAME
      end

      factory :batch_object_add_content_file do
        name Ddr::Models::File::CONTENT
        payload File.join(Rails.root, 'spec', 'fixtures', 'batch_ingest', 'miscellaneous', 'id001.tif')
        payload_type Ddr::Batch::BatchObjectFile::PAYLOAD_TYPE_FILENAME
        checksum "257fa1025245d2d2a60ae81ac7922ca9581ca314"
        checksum_type Ddr::Models::File::CHECKSUM_TYPE_SHA1
      end

    end

    factory :batch_object_addupdate_file do
      operation Ddr::Batch::BatchObjectFile::OPERATION_ADDUPDATE
    end

  end

end
