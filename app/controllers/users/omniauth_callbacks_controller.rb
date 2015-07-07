class Users::OmniauthCallbacksController < Devise::MultiAuth::OmniauthCallbacksController
  def cas
    @user = User.from_cas(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user
      set_flash_message(:notice, :success, kind: "CAS") if is_navigational_format?
    else
      session['devise.cas_data']  = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
