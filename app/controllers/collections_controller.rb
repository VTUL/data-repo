class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior

  def create
    @collection.apply_depositor_metadata(current_user.user_key)
    add_members_to_collection unless batch.empty?
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
end
