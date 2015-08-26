class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

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
        doi_request = DoiRequest.new(collection_id: @collection.id)
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
      after_update
    else
      after_update_error
    end
  end
 
end
