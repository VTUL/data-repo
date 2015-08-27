class DoiRequestsController < ApplicationController

  load_and_authorize_resource except: [:create]

  before_action :find_ezid_doi, :only => [:view_doi, :modify_metadata]

  def index
    @doi_requests = DoiRequest.sorted
  end

  def pending
    @doi_requests = DoiRequest.pending
    render('index')
  end

  def create
    klass = Object.const_get params[:asset_type]
    @asset = klass.find(params[:asset_id])
    @asset[:identifier] << t('doi.pending_doi')
    doi_request = DoiRequest.new(asset_id: params[:asset_id], asset_type: params[:asset_type])
    if doi_request.save && @asset.update_attributes({:identifier => @asset[:identifier]})
      flash[:notice] = t('doi.messages.submit.success')
      if klass == Collection
        redirect_to collections.collection_path(@asset)
      else # TODO: redirect to the other asset type show page
        redirect_to doi_requests_path
      end
    else
      flash[:error] = t('doi.messages.submit.failure')
      redirect_to doi_requests_path
    end
  end

  def mint_doi
    @doi_request = DoiRequest.find(params[:id])

    if @doi_request.collection?
      @collection = Collection.find(@doi_request.asset_id)
      minted_doi = Ezid::Identifier.create(
      	datacite_creator: (@collection.creator.empty? ? "" : @collection.creator.first), 
        datacite_resourcetype: "Collection",
        datacite_title: @collection.title,
        datacite_publisher: (@collection.publisher.empty? ? "" : @collection.publisher.first), 
        datacite_publicationyear: (@collection.date_created.empty? ? "" : @collection.date_created.first)
         )
      @collection[:identifier].each_with_index {
        |id, idx| id == t('doi.pending_doi') ? @collection[:identifier][idx] = minted_doi.id : id
      }
      if @doi_request.update_attributes({:ezid_doi => minted_doi.id}) && 
        @collection.update_attributes({:identifier => @collection[:identifier]})
        flash[:notice] = t('doi.messages.mint.success')
        redirect_to collections.collection_path(@doi_request.asset_id)
      else
        flash[:error] = t('doi.messages.mint.failure')
        redirect_to doi_requests_path
      end
    else
      redirect_to doi_requests_path
    end
  end

  def mint_all
  end

  def view_doi
  end

  private

  def find_ezid_doi
    if params[:id]
      @doi_request = DoiRequest.find(params[:id])
      @ezid_doi = Ezid::Identifier.find(@doi_request.ezid_doi)
    end
  end

end

