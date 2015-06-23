class ApplicationController < ActionController::Base
  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym 
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  
# Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  include Hydra::Controller::ControllerBehavior
  layout 'sufia-one-column'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
