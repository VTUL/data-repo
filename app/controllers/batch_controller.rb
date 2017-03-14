class BatchController < ApplicationController
  include Sufia::BatchControllerBehavior

  self.edit_form_class = DatarepoFileEditForm
  
  def edit
    super
    unless current_user.admin?
      self.edit_form_class.terms -= [:provenance]
    end
  end
end
