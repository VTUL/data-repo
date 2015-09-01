class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  skip_load_and_authorize_resource :only => [:datacite_search, :crossref_search, :import_metadata]

  def presenter_class
    MyCollectionPresenter
  end

  def form_class
    MyCollectionEditForm
  end

  def create
    @collection.apply_depositor_metadata(current_user.user_key)
    add_members_to_collection unless batch.empty?

    if !params[:collection][:funder].nil? && !params[:collection][:funder].empty?
      params[:collection][:funder].each do |funder|
        if funder.length > 0
          values = funder.split(":")
          @collection[:funder] << "<funder><fundername>#{values[0]}</fundername><awardnumber>#{values[1]}</awardnumber></funder>"
        end
      end
    end

    if @collection.save
      if params[:request_doi]
        @collection[:identifier] << t('doi.pending_doi')
        doi_request = DoiRequest.new(asset_id: @collection.id)
        if doi_request.save && @collection.update_attributes({:identifier => @collection[:identifier]})
          flash[:notice] = t('doi.messages.submit.success')
        else
          flash[:error] = t('doi.messages.submit.failure')
        end
      end
      
      after_create
    else
      after_create_error
    end
  end

  def update
    process_member_changes
    if @collection.update(collection_params.except(:members))
      newfunder = []
      if !params[:collection][:funder].nil? && !params[:collection][:funder].empty?
        params[:collection][:funder].each do |funder|
          if funder.length > 0
            values = funder.split(":")
            newfunder << "<funder><fundername>#{values[0]}</fundername><awardnumber>#{values[1]}</awardnumber></funder>"
          end
        end
      end
      @collection.update_attributes({:funder => newfunder})
      @collection[:identifier].each do |id|
        # Matches DOIs minted by VT Libraries 
        if /\A#{Ezid::Client.config.default_shoulder}/ =~ id
          ezid_doi = Ezid::Identifier.find(id)
          if ezid_doi
            ezid_doi.update_metadata(
              datacite_creator: (@collection.creator.empty? ? "" : @collection.creator.first), 
              datacite_title: @collection.title,
              datacite_publisher: (@collection.publisher.empty? ? "" : @collection.publisher.first), 
              datacite_publicationyear: (@collection.date_created.empty? ? "" : @collection.date_created.first)
            )
          end
          if ezid_doi.save
            flash[:notice] = t('doi.messages.modify.success')
          else
            flash[:error] = t('doi.messages.modify.failure')
          end
          break
        end
      end
      after_update
    else
      after_update_error
    end
  end

  def datacite_search
    uri = URI('http://search.datacite.org/api?')
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get(uri)
    parsed = JSON.parse(res)
    if parsed["responseHeader"]["status"] != 0
      @datacite_error = "Datacite server problem. You can fill in on your own."
      render :action => 'datacite_search_error'
    elsif parsed["response"]["numFound"] == 0
      @datacite_error = "No metadata found! You can fill in on your own."
      render :action => 'datacite_search_error'
    else      
      @results = parsed["response"]["docs"]
    end
  end

  def crossref_search
    @results = JSON.parse(params[:results])
  end

  def import_metadata
    @result = params[:result].gsub('=>', ':')
  end
 
end
