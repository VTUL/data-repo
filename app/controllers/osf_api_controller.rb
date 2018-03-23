class OsfAPIController < OsfAuthController
  require 'fileutils'
  require 'vtech_data/zip_file_generator'
  require 'vtech_data/osf_import_tools'
  require "#{Rails.root}/app/jobs/osf_import_job"

  helper_method :detail_route
  helper_method :import_route

  before_action :check_logged_in, only: [:list, :detail, :import]
  before_action :get_oauth_token

  def list
    osf_import_tools = OsfImportTools.new(@oauth_token, current_user)
    @projects = osf_import_tools.get_user_projects
  end

  def detail
    osf_import_tools = OsfImportTools.new(@oauth_token, current_user)
    @project = osf_import_tools.get_project_details(node_url_from_id(params["project_id"]))
  end

  def import
   osf_job = OsfImportJob.new(@oauth_token, params["project_id"], current_user)
   osf_job.run
   #Sufia.queue.push(OsfImportJob.new(@oauth_token, params["project_id"], current_user))
   redirect_to '/dashboard'
  end


  def detail_route project_id
    "/osf_api/detail/#{project_id}"
  end

  def import_route project_id
    "/osf_api/import/#{project_id}"
  end

  def get_oauth_token
    @oauth_token = oauth_token
  end

  def node_url_from_id node_id
    File.join(Rails.application.config.osf_api_base_url, "nodes", node_id, "/")  
  end

  def check_logged_in
    redirect_to oauth_auth_url unless session['oauth_token']
  end

end
