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
    doi_request = DoiRequest.new(asset_id: params[:asset_id], asset_type: params[:asset_type])
    if doi_request.save && @asset.update_attributes({:identifier => @asset.identifier.to_a.push(t('doi.pending_doi'))})
      flash[:notice] = t('doi.messages.submit.success')
      redirect_to collections.collection_path(@asset)
    else
      flash[:error] = t('doi.messages.submit.failure')
      redirect_to dashboard_publishables_path
    end
  end

  def mint_doi
    doi_request = DoiRequest.find(params[:id])
    Sufia.queue.push(AssignDoiJob.new(doi_request.id))
    flash[:notice] = "Your request has been processing in the background. Please come back later for the assigned doi."
    redirect_to doi_requests_path
  end

  def mint_all
    params[:doi_requests_checkbox].each do |id|
      doi_request = DoiRequest.find(id)
      Sufia.queue.push(AssignDoiJob.new(doi_request.id))
    end
    flash[:notice] = "Your request have been processing in the background. Please come back later for the assigned dois."
    redirect_to doi_requests_path
  end

  def view_doi
    @doi_request = DoiRequest.find(params[:id])
    @ezid_doi = Ezid::Identifier.find(@doi_request.ezid_doi)
  end

end

