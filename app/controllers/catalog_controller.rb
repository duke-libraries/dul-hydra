# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog
  include DulHydra::CatalogControllerBehavior

  # Adds method from Blacklight::SolrHelper to helper context
  helper_method :get_solr_response_for_doc_id
  helper_method :get_solr_response_for_field_values

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only => :show

  layout 'blacklight'

  # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  CatalogController.solr_search_params_logic += [:exclude_unwanted_models] unless DulHydra.unwanted_models.blank?

  configure_blacklight do |config|

    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10 
    }

    # solr field configuration for search results/index views
    config.index.show_link = DulHydra::IndexFields::TITLE
    config.index.record_display_type = DulHydra::IndexFields::ACTIVE_FEDORA_MODEL

    # solr field configuration for document/show views
    config.show.html_title = DulHydra::IndexFields::TITLE
    config.show.heading = DulHydra::IndexFields::TITLE
    config.show.display_type = DulHydra::IndexFields::HAS_MODEL

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
    config.add_facet_field DulHydra::IndexFields::ACTIVE_FEDORA_MODEL, :label => 'Type'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field DulHydra::IndexFields::ACTIVE_FEDORA_MODEL, :label => 'Type:'
    config.add_index_field 'id', :label => 'PID:'
    config.add_index_field DulHydra::IndexFields::IDENTIFIER, :label => 'Identifier:'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field DulHydra::IndexFields::ACTIVE_FEDORA_MODEL, :label => 'Type:'
    config.add_show_field 'id', :label => 'PID:'
    config.add_show_field DulHydra::IndexFields::IDENTIFIER, :label => 'Identifier:'

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
        :qf => "id active_fedora_model_ssi title_tesim creator_tesim subject_tesim description_tesim identifier_tesim"
      }
    end
    
    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

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
        :qf => DulHydra::IndexFields::IDENTIFIER
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
    config.add_sort_field 'score desc', :label => 'Relevance'
    config.add_sort_field "#{DulHydra::IndexFields::TITLE} asc", :label => 'Title'
    config.add_sort_field "#{DulHydra::IndexFields::IDENTIFIER} asc", :label => 'Identifier'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end 
