class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior
  before_action :authenticate_user!
  before_action :admin_only, only: [:index]
  before_action :admin_and_user_only, only: [:show]

  private

    def admin_only
      redirect_to root_path, alert: 'Permission denied: cannot access this page.' unless current_user.admin?
    end

    def admin_and_user_only
      unless @user == current_user || current_user.admin?
        redirect_to sufia.profile_path(current_user.to_param), alert: 'Permission denied: cannot access this page.'
      end
    end
end
