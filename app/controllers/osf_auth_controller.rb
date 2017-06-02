class OsfAuthController < ApplicationController
before_action :get_client

  def index
  end

  def auth
    auth_url = @client.auth_code.authorize_url(
      :redirect_uri => callback_url,
      :scope => 'osf.full_read',
      :response_type => 'code',
      :state => 'iuasdhf734t9hiwlf7'
    )
    redirect_to auth_url
  end

  def token
  end

  def callback
    code = params['code']
    if !code.blank?
      oauth_token = @client.auth_code.get_token(code, :redirect_uri => callback_url)
      if !oauth_token.blank?
        session['oauth_token'] = oauth_token
        redirect_to api_list_url 
      end
    end
  end

  def callback_url
    "#{request.base_url}/osf_auth/callback/"
  end

  def get_client
    @client ||=  OAuth2::Client.new(
      Rails.application.secrets['osf']['client_id'],
      Rails.application.secrets['osf']['client_secret'],
      :site => Rails.application.config.osf_auth_site,
      :authorize_url=> Rails.application.config.osf_authorize_url,
      :token_url=> Rails.application.config.osf_token_url
    )
  end

  def oauth_token
    @oauth_token = OAuth2::AccessToken.from_hash(get_client, session['oauth_token'])
  end

end

