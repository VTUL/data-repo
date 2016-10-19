# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  self. presenter_class = DatarepoGenericFilePresenter

  self.edit_form_class = DatarepoFileEditForm
end
