require 'spec_helper'

def component_solr_doc_array
  component_solr_hash_array.map { |h| SolrDocument.new(h) }
end

def component_solr_hash_array
  [ {"system_create_dtsi"=>"2015-04-07T19:04:19Z", "system_modified_dtsi"=>"2015-04-07T19:04:22Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:514", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:22Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"5b8d8c31c079c71122da52b6279270be81c9985a6bed87ea1e6aa0f242d39e20\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:22Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"e7947a36309c4c07305f0d8dd1f1a796b3bc8bb1fe9b820b81ef9e9651cdf228\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:20Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"6fef8f418dd099081e5208113d02898f6cca11c5ff1f32f8bfb9b0cecdef72d4\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:22Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"f10b62bb1da58236e2a5dae38db75c30c07e888eb37db7a73ca795d5c6981e13\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:19Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:22Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:514+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"9037f07124368677f8ea8f527a18f525cea9439d1e11e7bc342acc0ccb0b4617\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:19Z\",\"objLastModDate\":\"2015-04-07T19:04:19Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A514/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A514/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00001"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00001", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:511"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:514", "identifier_ssi"=>"cmp00001", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:18.943Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821047093723136, "timestamp"=>"2015-04-07T19:04:23.186Z"},
    {"system_create_dtsi"=>"2015-04-07T19:04:21Z", "system_modified_dtsi"=>"2015-04-07T19:04:23Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:515", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:23Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"758386d73cd1b43c2618ab1df3e1d9cba117a6ea32e76a8509d9fc950471ab90\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:23Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"c24a0133854c88d62d59482daabd1da96a627eb51f47b96ae4055d5417dc405e\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:22Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"109ba9b2501e6e3f4311f991336565ada86f7ffba0ec4c4fb479b57c2c8e189a\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:23Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"d2514424ca763012f9de68d7b6b9c7102fffdbe59b1797023e7459e6d1881392\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:21Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:23Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:515+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"3fd6a044254f7f955851599cae9ce31e685939922f9c61d2cfc9586ae496ce81\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:21Z\",\"objLastModDate\":\"2015-04-07T19:04:21Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A515/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A515/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00002"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00002", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:511"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:515", "identifier_ssi"=>"cmp00002", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:21.152Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821047634788352, "timestamp"=>"2015-04-07T19:04:23.702Z"},
    {"system_create_dtsi"=>"2015-04-07T19:04:24Z", "system_modified_dtsi"=>"2015-04-07T19:04:27Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:516", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"c9c1d50dbdde0df59d63b54b978067f60190e1c474d807b31ed676905e0534b4\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"49e8f968051349da13e581d4f5a648d44ddbe0496da872c9805d31abc7a0a450\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:24Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"665c3e947b69ed94570e3714bbbe86e7ff154a1d45d4ed268e81c7c0ccbd97f0\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"88e58ece18c7865154a6be823144818c45a4c2af5b65f5b846f68757fdcfbb64\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:24Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:516+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"1f785f34f0b0165542341cc07b280eb6dee43543163f180c16c034598d249d60\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:24Z\",\"objLastModDate\":\"2015-04-07T19:04:24Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A516/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A516/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00003"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00003", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:512"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:516", "identifier_ssi"=>"cmp00003", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:24.063Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821051641397248, "timestamp"=>"2015-04-07T19:04:27.523Z"},
    {"system_create_dtsi"=>"2015-04-07T19:04:25Z", "system_modified_dtsi"=>"2015-04-07T19:04:27Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:517", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"1536f5fa25fb5a3f9d5f629dd085ae40956dc2ee06ce626ae962b875fd56fbff\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"247c2af6d5f682ecad7f9370a7abeea563656402b2d13a877807a61ed45ade6f\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:26Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"713a6448548728d2856799961d5c0f8bd287cc93b2a95f1621551f48206e3e89\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"e006faca08b08a6a43e584bbc9277ecc1987652dd666c8d576a00d8091216664\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:26Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:27Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:517+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"a983b38d8affd0b850599e512e6d0bfe2c4375204cde04b2463cedb7e6c09b9a\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:25Z\",\"objLastModDate\":\"2015-04-07T19:04:25Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A517/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A517/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00004"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00004", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:512"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:517", "identifier_ssi"=>"cmp00004", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:25.619Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821052104867840, "timestamp"=>"2015-04-07T19:04:27.965Z"},
    {"system_create_dtsi"=>"2015-04-07T19:04:28Z", "system_modified_dtsi"=>"2015-04-07T19:04:31Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:518", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"4bc9c24e4a469ae085bdaf9ac990a33e660279796f68ee9940b6b6fdf8d19701\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"c43193e5cf5b7d0e85f4e3c30e9bd36be71cac82cbae34e22456fdf335f200ec\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:29Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"acd21ac6beab40a2cdab445944e9c0c83f3bf3ebfbff35b55c464d0f4814415f\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"300fba68947c3312f5ea8dbf5d98c3a32b8d3378aa404dbdc7cf655473a94d31\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:28Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:518+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"e4f593a45f677657ac2232bc519072a2c6643ef87dda1d3ec3bf70634c12b474\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:28Z\",\"objLastModDate\":\"2015-04-07T19:04:28Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A518/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A518/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00005"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00005", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:513"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:518", "identifier_ssi"=>"cmp00005", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:28.238Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821056138739712, "timestamp"=>"2015-04-07T19:04:31.812Z"},
    {"system_create_dtsi"=>"2015-04-07T19:04:30Z", "system_modified_dtsi"=>"2015-04-07T19:04:32Z", "object_state_ssi"=>"A", "active_fedora_model_ssi"=>"Component", "id"=>"changeme:519", "object_profile_ssm"=>["{\"datastreams\":{\"RELS-EXT\":{\"dsLabel\":\"Fedora Object-to-Object Relationship Metadata\",\"dsVersionID\":\"RELS-EXT.1\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/rdf+xml\",\"dsFormatURI\":null,\"dsControlGroup\":\"X\",\"dsSize\":420,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+RELS-EXT+RELS-EXT.1\",\"dsLocationType\":null,\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"6ed5f7315fb72f4a24c1d1d22805843d327caad135bfb39f2348b969e0c8b773\"},\"descMetadata\":{\"dsLabel\":\"Descriptive Metadata for this object\",\"dsVersionID\":\"descMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":157,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+descMetadata+descMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"2d8ac941c9131db2290fe0f7b5a60d6abfb7c5ce3022c71d96ac67eb9de0bfc3\"},\"rightsMetadata\":{},\"properties\":{},\"thumbnail\":{\"dsLabel\":\"Thumbnail for this object\",\"dsVersionID\":\"thumbnail.0\",\"dsCreateDate\":\"2015-04-07T19:04:30Z\",\"dsState\":\"A\",\"dsMIME\":\"image/png\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":9857,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+thumbnail+thumbnail.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"384c244d65a0969cca2c17ee8a7d4df07f50a8d757ad0e10ed066adcf44875f3\"},\"adminMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"adminMetadata.3\",\"dsCreateDate\":\"2015-04-07T19:04:31Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":101,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+adminMetadata+adminMetadata.3\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"70721f5824f9588005b3c5e13e32f83f92744deeb3ee0f35fcd7048f11e6d7a1\"},\"content\":{\"dsLabel\":\"library-devil.tiff\",\"dsVersionID\":\"content.0\",\"dsCreateDate\":\"2015-04-07T19:04:30Z\",\"dsState\":\"A\",\"dsMIME\":\"image/tiff\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":10032,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+content+content.0\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"dea56f15b309e47b74fa24797f85245dda0ca3d274644a96804438bbd659555a\"},\"structMetadata\":{\"dsLabel\":null,\"dsVersionID\":\"structMetadata.1\",\"dsCreateDate\":\"2015-04-07T19:04:32Z\",\"dsState\":\"A\",\"dsMIME\":\"application/n-triples\",\"dsFormatURI\":null,\"dsControlGroup\":\"M\",\"dsSize\":314,\"dsVersionable\":true,\"dsInfoType\":null,\"dsLocation\":\"changeme:519+structMetadata+structMetadata.1\",\"dsLocationType\":\"INTERNAL_ID\",\"dsChecksumType\":\"SHA-256\",\"dsChecksum\":\"87f30e39f9dd10c972b8e2fcb906c904c4db007629d2f67e793c7e9b36d9f61b\"}},\"objLabel\":null,\"objOwnerId\":\"fedoraAdmin\",\"objModels\":[\"info:fedora/fedora-system:FedoraObject-3.0\"],\"objCreateDate\":\"2015-04-07T19:04:30Z\",\"objLastModDate\":\"2015-04-07T19:04:30Z\",\"objDissIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A519/methods/fedora-system%3A3/viewMethodIndex\",\"objItemIndexViewURL\":\"http://localhost:8983/fedora/objects/changeme%3A519/methods/fedora-system%3A3/viewItemIndex\",\"objState\":\"A\"}"], "identifier_tesim"=>["cmp00006"], "title_tesim"=>["Test Component"], "admin_metadata__original_filename_ssi"=>"library-devil.tiff", "struct_metadata__file_use_ssi"=>"master", "struct_metadata__order_isi"=>1, "struct_metadata__file_group_ssi"=>"cmp00006", "has_model_ssim"=>["info:fedora/afmodel:Component"], "is_part_of_ssim"=>["info:fedora/changeme:513"], "title_ssi"=>"Test Component", "internal_uri_ssi"=>"info:fedora/changeme:519", "identifier_ssi"=>"cmp00006", "last_virus_check_on_dtsi"=>"2015-04-07T19:04:29.92Z", "last_virus_check_outcome_ssim"=>["failure"], "content_size_isi"=>10032, "content_size_human_ssim"=>["9.8 KB"], "content_media_type_ssim"=>["image/tiff"], "collection_uri_ssim"=>["info:fedora/changeme:510"], "_version_"=>1497821056614793216, "timestamp"=>"2015-04-07T19:04:32.265Z"}
  ]
end
