class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior
  prepend_before_action :find_user, except: [:index, :search, :notifications_number, :depositor_list_export, :user_analytics_export]
  before_action :authenticate_user!
  before_action :require_admin, only: [:depositor_list_export, :user_analytics_export]
  before_action :admin_and_user_only, only: [:show]

  def depositor_list_export
    Sufia.queue.push(DepositorExportJob.new(current_user, request.base_url))
    redirect_to sufia.dashboard_index_path, notice: 'Your export is running in the background. You should receive an email when it is complete.'
  end

  def user_analytics_export
    UserAnalyticsExportJob.new(current_user, request.base_url).run
#    Sufia.queue.push(UserAnalyticsExportJob.new(current_user, request.base_url))
    redirect_to sufia.dashboard_index_path, notice: 'Your export is running in the background. You should receive an email when it is complete.'
  end

  private

    def admin_and_user_only
      unless @user == current_user || current_user.admin?
        redirect_to sufia.profile_path(current_user.to_param), alert: 'Permission denied: cannot access this page.'
      end
    end

    def require_admin
      unless current_user.admin?
        redirect_to sufia.profile_path(current_user.to_param), alert: 'Permission denied: cannot access this page.'
      end
    end

end
