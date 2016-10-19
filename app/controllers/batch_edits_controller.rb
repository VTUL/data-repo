class BatchEditsController < ApplicationController
  include Hydra::BatchEditBehavior
  include GenericFileHelper
  include Sufia::BatchEditsControllerBehavior

  def terms
    DatarepoFileEditForm.terms
  end

  def generic_file_params
    DatarepoFileEditForm.model_attributes(params[:generic_file])
  end
end

