class Users::OmniauthCallbacksController < Devise::MultiAuth::OmniauthCallbacksController
  def cas
    @user = User.from_cas(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
    else
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end
