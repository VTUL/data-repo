class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  include CurationConcerns::ThemedLayoutController
  with_themed_layout '1_column'


  protect_from_forgery with: :exception
end
