class DoiRequestsController < ApplicationController

  load_and_authorize_resource except: [:create]

  def index
    @doi_requests = DoiRequest.sorted
    # set up batch assignment upper limit
    @max_batch_size = 80
    @num_requests = @doi_requests.count { |r| !r.completed? }
    @disable_select_all = (@num_requests > @max_batch_size) || (@num_requests == 0)
    @all_checked = false
  end

  def pending
    @doi_requests = DoiRequest.pending
    # set up batch assignment upper limit
    @max_batch_size = 80
    @num_requests = @doi_requests.count
    @disable_select_all = (@num_requests > @max_batch_size) || (@num_requests == 0)
    @all_checked = false
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
    doi_request = DoiRequest.find(params[:id])
    klass = Object.const_get doi_request.asset_type
    asset = klass.find(doi_request.asset_id)
    minted_doi = Ezid::Identifier.create(
      datacite_creator: (asset.creator.empty? ? "" : asset.creator.first), 
      datacite_resourcetype: (doi_request.collection? ? "Dataset" : doi_request.asset_type),
      datacite_title: asset.title,
      datacite_publisher: (asset.publisher.empty? ? "" : asset.publisher.first), 
      datacite_publicationyear: (asset.date_created.empty? ? "" : asset.date_created.first)
     )
    asset[:identifier].each_with_index {
      |id, idx| id == t('doi.pending_doi') ? asset[:identifier][idx] = minted_doi.id : id
    }
    if doi_request.update_attributes({:ezid_doi => minted_doi.id}) && 
        asset.update_attributes({:identifier => asset[:identifier]})
      flash[:notice] = t('doi.messages.mint.success')
      redirect_to doi_requests_path
    else
      flash[:error] = t('doi.messages.mint.failure')
      redirect_to doi_requests_path
    end
  end

  def mint_all
    mint_success = true
    params[:doi_requests_checkbox].each do |id|
      doi_request = DoiRequest.find(id)
      klass = Object.const_get doi_request.asset_type
      asset = klass.find(doi_request.asset_id)
      minted_doi = Ezid::Identifier.create(
        datacite_creator: (asset.creator.empty? ? "" : asset.creator.first), 
        datacite_resourcetype: (doi_request.collection? ? "Dataset" : doi_request.asset_type),
        datacite_title: asset.title,
        datacite_publisher: (asset.publisher.empty? ? "" : asset.publisher.first), 
        datacite_publicationyear: (asset.date_created.empty? ? "" : asset.date_created.first)
       )
      asset[:identifier].each_with_index {
        |id, idx| id == t('doi.pending_doi') ? asset[:identifier][idx] = minted_doi.id : id
      }
      if !(doi_request.update_attributes({:ezid_doi => minted_doi.id}) && 
          asset.update_attributes({:identifier => asset[:identifier]}))
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

end

