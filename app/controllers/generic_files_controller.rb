# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  self. presenter_class = DatarepoGenericFilePresenter

  self.edit_form_class = DatarepoFileEditForm

  def edit
		super
		unless current_user.admin?                                                                         
			self.edit_form_class.terms -= [:provenance]                                                  
			@provenance_display = "records/show_fields/provenance"
		end 
  end

  # routed to /files/:id (PUT)
  def update
    success =
      if wants_to_revert?
        update_version
      elsif wants_to_upload_new_version?
        update_file
      elsif params.key? :generic_file
        update_metadata
      elsif params.key? :visibility
        update_visibility
      end
    if success
      redirect_to sufia.generic_file_path(@generic_file), notice:
        'File was successfully updated.'
    else
      flash[:error] ||= 'Update was unsuccessful.'
      set_variables_for_edit_form
      render action: 'edit'
    end
  end

  def new
    super
    redirect_to sufia.dashboard_index_path, alert: "Sorry, you are not authorized to view that page" if (current_user.blank? || !current_user.admin?)
  end

end
