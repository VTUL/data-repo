class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  before_action :non_admin_redirect

  def admin_metadata_download
    Sufia.queue.push(AdminMetadataExportJob.new(request.base_url, current_user))
    redirect_to sufia.dashboard_index_path, notice: 'Your export is running in the background. You should receive an email when it is complete.'    
  end

  def non_admin_redirect
    redirect_to root_path, alert: "Sorry, you are not authorized to view that page" if (current_user.blank? || !current_user.admin?)
  end
end
