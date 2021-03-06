# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Blacklight::Catalog

  # Adds method from Blacklight::SolrHelper to helper context
  helper_method :get_solr_response_for_doc_id
  helper_method :get_solr_response_for_field_values

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only => :show

  layout 'blacklight'

  configure_blacklight do |config|

    config.default_solr_params = {
      :qt => 'search',
      :rows => 10
    }

    # solr field configuration for search results/index views
    config.index.title_field = Ddr::Index::Fields::TITLE
    config.index.display_type_field = Ddr::Index::Fields::ACTIVE_FEDORA_MODEL

    config.index.thumbnail_method = :thumbnail_image_tag

    # solr field configuration for document/show views
    config.show.title_field = Ddr::Index::Fields::TITLE
    config.show.display_type_field = Ddr::Index::Fields::HAS_MODEL

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, :label => 'Type'
    config.add_facet_field Ddr::Index::Fields::ADMIN_SET_FACET.to_s, label: 'Admin Set',
                           helper_method: 'admin_set_title'
    config.add_facet_field Ddr::Index::Fields::WORKFLOW_STATE.to_s, label: 'Publication Status', query: {
        published: { label: 'Published', fq: "#{Ddr::Index::Fields::WORKFLOW_STATE}:published" },
        not_published: { label: 'Not Published', fq: "-#{Ddr::Index::Fields::WORKFLOW_STATE}:published" }
    }
    config.add_facet_field Ddr::Index::Fields::IS_LOCKED.to_s, label: 'Lock Status', query: {
        locked: { label: 'Locked', fq: "#{Ddr::Index::Fields::IS_LOCKED}:true" },
        not_locked: { label: 'Not Locked', fq: "-#{Ddr::Index::Fields::IS_LOCKED}:true" }
    }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    # config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, :label => 'Type'
    config.add_index_field Ddr::Index::Fields::PERMANENT_ID.to_s, :label => 'Permanent ID'
    config.add_index_field 'id', :label => 'Fedora PID'
    config.add_index_field Ddr::Index::Fields::IDENTIFIER_ALL.to_s, :label => 'Identifier'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, :label => 'Type'
    config.add_show_field 'id', :label => 'PID'
    config.add_show_field Ddr::Index::Fields::IDENTIFIER_ALL.to_s, :label => 'Identifier'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', :label => 'All Fields') do |field|
      field.solr_local_parameters = {
        :qf => ["id",
                solr_name(:abstract, :stored_searchable),
                solr_name(:affiliation, :stored_searchable),
                solr_name(:alternative, :stored_searchable),
                solr_name(:artist, :stored_searchable),
                solr_name(:biblical_book, :stored_searchable),
                solr_name(:bibliographicCitation, :stored_searchable),
                solr_name(:box_number, :stored_searchable),
                solr_name(:call_number, :stored_searchable),
                solr_name(:category, :stored_searchable),
                solr_name(:chapter_and_verse, :stored_searchable),
                solr_name(:company, :stored_searchable),
                solr_name(:composer, :stored_searchable),
                solr_name(:creator, :stored_searchable),
                solr_name(:contributor, :stored_searchable),
                solr_name(:description, :stored_searchable),
                solr_name(:dedicatee, :stored_searchable),
                solr_name(:engraver, :stored_searchable),
                solr_name(:extent, :stored_searchable),
                solr_name(:folder, :stored_searchable),
                solr_name(:format, :stored_searchable),
                solr_name(:genre, :stored_searchable),
                solr_name(:headline, :stored_searchable),
                solr_name(:identifier, :stored_searchable),
                solr_name(:illustrated,:stored_searchable),
                solr_name(:illustrator,:stored_searchable),
                solr_name(:instrumentation, :stored_searchable),
                solr_name(:interviewer_name, :stored_searchable),
                solr_name(:isPartOf, :stored_searchable),
                solr_name(:issue_number, :stored_searchable),
                solr_name(:language_name, :stored_searchable),
                solr_name(:lithographer, :stored_searchable),
                solr_name(:lyricist, :stored_searchable),
                solr_name(:medium, :stored_searchable),
                solr_name(:negative_number, :stored_searchable),
                solr_name(:nested_path_text, :searchable),
                solr_name(:oclc_number, :stored_searchable),
                solr_name(:performer, :stored_searchable),
                solr_name(:placement_company, :stored_searchable),
                solr_name(:print_number, :stored_searchable),
                solr_name(:producer, :stored_searchable),
                solr_name(:product, :stored_searchable),
                solr_name(:provenance, :stored_searchable),
                solr_name(:publication, :stored_searchable),
                solr_name(:publisher, :stored_searchable),
                solr_name(:rights, :stored_searchable),
                solr_name(:roll_number, :stored_searchable),
                solr_name(:series, :stored_searchable),
                solr_name(:setting, :stored_searchable),
                solr_name(:spatial, :stored_searchable),
                solr_name(:sponsor, :stored_searchable),
                solr_name(:subject, :stored_searchable),
                solr_name(:subseries, :stored_searchable),
                solr_name(:temporal, :stored_searchable),
                solr_name(:title, :stored_searchable),
                solr_name(:tone, :stored_searchable),
                solr_name(:type, :stored_searchable),
                solr_name(:volume, :stored_searchable),
                Ddr::Index::Fields::ALL_TEXT,
                Ddr::Index::Fields::LOCAL_ID,
                Ddr::Index::Fields::PERMANENT_ID,
                Ddr::Index::Fields::YEAR_FACET].join(' ')
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = { :'spellcheck.dictionary' => 'default' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('identifier') do |field|
      field.solr_local_parameters = {
        :qf => Ddr::Index::Fields::IDENTIFIER_ALL
      }
    end

    config.add_search_field('permanent_id', label: 'Permanent ID') do |field|
      field.solr_local_parameters = {
        :qf => Ddr::Index::Fields::PERMANENT_ID
      }
    end

    config.add_search_field('pid', :label => 'PID') do |field|
      field.solr_local_parameters = {
        :qf => 'id'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc', :label => 'Relevance', :default_for_user_query => true
    config.add_sort_field "#{Ddr::Index::Fields::TITLE} asc", :label => 'Title', :default => true
    config.add_sort_field "#{Ddr::Index::Fields::LOCAL_ID} asc", :label => 'Local ID'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end
