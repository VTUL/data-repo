class BatchEditsController < ApplicationController
  include Hydra::BatchEditBehavior
  include GenericFileHelper
  include Sufia::BatchEditsControllerBehavior

  def terms
		if current_user.admin?
			DatarepoFileEditForm.terms
		else
			DatarepoFileEditForm.terms -= [:provenance]
    end
  end

  def generic_file_params
    DatarepoFileEditForm.model_attributes(params[:generic_file])
  end
end

