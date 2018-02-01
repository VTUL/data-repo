class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior
  prepend_before_action :find_user, except: [:index, :search, :notifications_number, :depositor_list_export]
  before_action :authenticate_user!
  before_action :require_admin, only: [:depositor_list_export]
  before_action :admin_and_user_only, only: [:show]

  def depositor_list_export
    depositors = generate_depositor_list
    send_data depositors, filename: "#{Date.today}_depositors.csv"
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

    def generate_depositor_list
      attributes = %w{email name filename file_id datasets dataset_ids}
      CSV.generate(headers: true) do |csv|
        csv << attributes
        GenericFile.all.each do |file|
          email = file.depositor
          name = User.find_by(email: email).name
          filename = !file.filename.empty? ? file.filename : file.label
          file_id = file.id
          datasets = file.collections.map{ |c| c.title }.join("||")
          dataset_ids = file.collections.map{ |c| c.id }.join("||")
          csv << [email, name, filename, file_id, datasets, dataset_ids]
        end
      end
    end

end
