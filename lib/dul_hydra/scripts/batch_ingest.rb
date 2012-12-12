module DulHydra::Scripts
  module BatchIngest
    FEDORA_URI_PREFIX = "info:fedora/"
    IDENTIFIER = "identifier"
    OBJECTS = "objects"
    PROVIDED = "provided"
    CONTENTDM_SUBPATH = "contentdm/"
    DIGITIZATIONGUIDE_SUBPATH = "digitizationGuide/"
    FMPEXPORT_SUBPATH = "fmpExport/"
    MARCXML_SUBPATH = "marcXML/"
    MASTER_SUBPATH = "master/"
    QDC_SUBPATH = "qdc/"
    def self.prep_for_ingest(ingest_manifest)
      logger.debug("Ingest Manifest is #{ingest_manifest}")
      @manifest = YAML::load(File.open(ingest_manifest))
      logger.debug(ingest_manifest)
      @basepath = @manifest["basepath"]
      logger.debug("Base path is: #{@basepath}")
      master_source = @manifest["mastersource"] || OBJECTS
      unless master_source == PROVIDED
        master = Nokogiri::XML::Document.new
        objects_node = Nokogiri::XML::Node.new "objects", master
        master.root = objects_node
      end
      for object in @manifest[OBJECTS]
        key_identifier = case object[IDENTIFIER]
        when String
          object[IDENTIFIER]
        when Array
          object[IDENTIFIER].first
        end
        if master_source == OBJECTS
          model = object["model"] || @manifest["model"]
          object_node = Nokogiri::XML::Node.new "object", master
          object_node["model"] = "#{FEDORA_URI_PREFIX}#{model}"
          identifier_node = Nokogiri::XML::Node.new "identifier", master
          identifier_node.content = key_identifier
          logger.debug("Identifier content is: #{identifier_node.content}")
          object_node.add_child(identifier_node)
          objects_node.add_child(object_node)
        end
        case object["qdcsource"]
        when "marcxml"
          source_xml_path = case
          when object["marcxml"].blank?
            "#{@basepath}#{MARCXML_SUBPATH}#{identifier}.xml"
          when object["marcxml"].start_with?("/")
            object["marcxml"]
          else
            marcxml_filename = object["marcxml"]
            "#{@basepath}#{MARCXML_SUBPATH}#{marcxml_filename}"
          end
          logger.debug("MARCXML Source File: #{source_xml_path}")
          xsl_path = "/srv/fedora-working/ingest/bin/xslt/MARCXML2QDC.xsl"
          result_xml_path = "#{@basepath}#{QDC_SUBPATH}#{key_identifier}.xml"
          doc = Nokogiri::XML(File.open(source_xml_path))
          xslt = Nokogiri::XSLT(File.open(xsl_path))
          result_doc = xslt.transform(doc)
          File.open(result_xml_path, 'w') { |f| result_doc.write_xml_to f }
        end
      end
      unless master_source == PROVIDED
        File.open(master_path, "w") { |f| master.write_xml_to f }
      end
    end
    def self.ingest(ingest_manifest)
      logger.debug("Ingest Manifest is #{ingest_manifest}")
      manifest = YAML::load(File.open(ingest_manifest))
      logger.debug(ingest_manifest)
      manifest_apo = AdminPolicy.find(manifest["adminpolicy"]) unless manifest["adminpolicy"].blank?
      for object in manifest["objects"]
        apo = case
        when object["adminpolicy"] then AdminPolicy.find(object["adminpolicy"])
        when manifest_apo then manifest_apo
        end
        model = object["model"] || manifest["model"]
        if model.blank?
          raise "Missing model"
        end
        ingest_object = case model
        when "afmodel:Collection" then Collection.new
        when "afmodel:Item" then Item.new
        when "afmodel:Component" then Component.new
        else raise "Invalid model"
        end
        ingest_object.label = object["label"] || manifest["label"]
        ingest_object.identifier = object["identifier"]
        ingest_object.title = object["title"] || manifest["title"]
        ingest_object.admin_policy = apo unless apo.nil?
        ingest_object.save
        logger.debug("Ingest Object PID: #{ingest_object.pid}")
      end
    end
    
    private
    
    def self.master_path
      master_path = case
      when @manifest["master"].blank?
        "#{@basepath}#{MASTER_SUBPATH}master.xml"
      when manifest["master"].start_with?("/")
        manifest["master"]
      else
        master_filename = manifest["master"]
        "#{@basepath}#{MASTER_SUBPATH}#{master_filename}"
      end      
    end
  end
end