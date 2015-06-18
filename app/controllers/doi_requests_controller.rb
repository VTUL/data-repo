class DoiRequestsController < ApplicationController

  layout 'admin'
  
  def index
    @doi_requests = DoiRequest.sorted
  end

  def pending_requests
    @doi_requests = DoiRequest.pending
    render('index')
  end

  def completed_requests
    @doi_requests = DoiRequest.completed
    render('index')
  end

  def show
    @doi_request = DoiRequest.find(params[:id])
    @ezid_doi = Ezid::Identifier.find(@doi_request.ezid_doi)
  end

  def create
    if params[:collection_id].present?
      @collection = Collection.find(params[:collection_id])
      @collection[:identifier] << "doi:pending"
      puts params[:collection_id]
      doi_request = DoiRequest.new(asset_type: 'Collection', collection_id: params[:collection_id])
      if doi_request.save && @collection.update_attributes({:identifier => @collection[:identifier]})
        flash[:notice] = "DOI Request has been submitted successfully!"
      else
        flash[:error] = "DOI Request error!"
      end
      redirect_to(:controller => 'collections', :action => 'show', :id => params[:collection_id])
    else
      redirect_to(:action => 'index')
    end  
  end

  def mint_doi
    @doi_request = DoiRequest.find(params[:id])
    
    if @doi_request.asset_type == 'Collection'
      @collection = Collection.find(@doi_request.collection_id)
      minted_doi = Ezid::Identifier.create(
        datacite_creator: @collection.creator.first, 
        datacite_resourcetype: "Collection",
        datacite_title: @collection.title,
        datacite_publisher: @collection.publisher.first,
        datacite_publicationyear: @collection.date_created.first
         )
      @collection[:identifier].each_with_index {
        |id, idx| id == "doi:pending" ? @collection[:identifier][idx] = minted_doi.id : id
      }
      if @doi_request.update_attributes({:ezid_doi => minted_doi.id, :completed => true}) && @collection.update_attributes({:identifier => @collection[:identifier]})
        flash[:notice] = "DOI has been minted successfully!"
        redirect_to(:controller => 'collections', :action => 'show', :id => @doi_request.collection_id)
      else
        flash[:error] = "DOI Request error!"
        redirect_to(:action => 'index')
      end
    else
      redirect_to(:action => 'index')    
    end
  end

  def modify_metadata
    ezid_doi = Ezid::Identifier.find(params[:ezid_doi])
    @doi_request = DoiRequest.find(params[:id])
    if @doi_request.asset_type == 'Collection'
      @collection = Collection.find(@doi_request.collection_id)
      ezid_doi = Ezid::Identifier.update_metadata(
        datacite_creator: @collection.creator.first, 
        datacite_title: @collection.title,
        datacite_publisher: @collection.publisher.first,
        datacite_publicationyear: @collection.date_created.first
         )
      if ezid_doi
        flash[:notice] = "DOI metadata has been modified successfully!"
        redirect_to(:controller => 'collections', :action => 'show', :id => @doi_request.collection_id)
      else
        flash[:error] = "DOI modification error!" 
        redirect_to(:action => 'index')
      end
    else
      redirect_to(:action => 'index')
    end
  end

  def delete
    @doi_request = DoiRequest.find(params[:id])
  end

  def destroy
    doi_request = DoiRequest.find(params[:id]).destroy
    flash[:notice] = "DOI Request '#{doi_request.doi_id}' destroyed successfully!"
    redirect_to(:action => 'index')
  end

end

