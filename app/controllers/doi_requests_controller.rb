class DoiRequestsController < ApplicationController

  load_and_authorize_resource except: [:create]

  def index
    @doi_requests = DoiRequest.sorted.page(params[:page]).per(10)
  end

  def pending
    @doi_requests = DoiRequest.pending.page(params[:page]).per(10)
  end

  def create
    # For now, assume the asset_type is Collection only
    # if params[:asset_type] == "Collection"
    @asset = Collection.find(params[:asset_id])
    @asset[:identifier] << t('doi.pending_doi')
    doi_request = DoiRequest.new(asset_id: params[:asset_id], asset_type: params[:asset_type])
    if doi_request.save && @asset.update_attributes({:identifier => @asset[:identifier]})
      flash[:notice] = t('doi.messages.submit.success')
      redirect_to collections.collection_path(@asset)
    else
      flash[:error] = t('doi.messages.submit.failure')
      redirect_to doi_requests_path
    end
  end

  def mint_doi
    doi_request = DoiRequest.find(params[:id])
    if mint_collection_doi(doi_request)
      flash[:notice] = t('doi.messages.mint.success')
    else
      flash[:error] = t('doi.messages.mint.failure')
    end
    redirect_to doi_requests_path
  end

  def mint_all
    mint_success = true
    params[:doi_requests_checkbox].each do |id|
      doi_request = DoiRequest.find(id)
      if !mint_collection_doi(doi_request)
        mint_success = false
      end
    end
    if mint_success
      flash[:notice] = "Batch mint complete."
    else
      flash[:error] = "Error in batch mint."
    end
    redirect_to doi_requests_path
  end

  def view_doi
    @doi_request = DoiRequest.find(params[:id])
    @ezid_doi = Ezid::Identifier.find(@doi_request.ezid_doi)
  end

  private

    def mint_collection_doi(doi_request)
      asset = Collection.find(doi_request.asset_id)
      minted_doi = Ezid::Identifier.create(
        datacite_creator: (asset.creator.empty? ? "" : asset.creator.first), 
        datacite_resourcetype: "Dataset",
        datacite_title: asset.title,
        datacite_publisher: (asset.publisher.empty? ? "" : asset.publisher.first), 
        datacite_publicationyear: (asset.date_created.empty? ? "" : asset.date_created.first)
       )
      asset[:identifier].each_with_index {
        |id, idx| id == t('doi.pending_doi') ? asset[:identifier][idx] = minted_doi.id : id
      }  
      return doi_request.update_attributes({:ezid_doi => minted_doi.id}) && 
        asset.update_attributes({:identifier => asset[:identifier]})
    end

end

