class OsfAPIController < OsfAuthController
  require 'fileutils'
  require 'vtech_data/zip_file_generator'
  require 'vtech_data/osf_import_tools'
  require "#{Rails.root}/app/jobs/osf_import_job"

  helper_method :detail_route
  helper_method :import_route

  before_action :check_logged_in, only: [:detail, :import]

  def detail
    osf_import_tools = OsfImportTools.new(oauth_token, current_user)
    @project = osf_import_tools.get_project_details(node_url_from_id(params["project_id"]))
  end

  def import
    osf_job = OsfImportJob.new(oauth_token, params["project_id"], current_user)
    osf_job.run
   #Sufia.queue.push(OsfImportJob.new(@oauth_token, params["project_id"], current_user))
   redirect_to '/dashboard', notice: 'Your project is currently being imported. You should receive an email when the process has completed.'
  end

  def get_oauth_token
    @oauth_token = oauth_token
  end

  def node_url_from_id node_id
    File.join(Rails.application.config.osf_api_base_url, "nodes", node_id, "/")  
  end

end
