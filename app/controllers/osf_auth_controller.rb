class OsfAuthController < ApplicationController
  before_action :get_client
  helper_method :auth_url
  helper_method :detail_route
  helper_method :import_route

  def index
  end

  def auth
    redirect_to auth_url
  end

  def token
  end

  def callback
    code = params['code']
    if !code.blank?
      token = @client.auth_code.get_token(code, :redirect_uri => callback_url)
      if !token.blank?
        session['oauth_token'] = token.to_json
        redirect_to '/files/new#osf' 
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
    @oauth_token ||= OAuth2::AccessToken.from_hash(get_client, JSON.parse(session['oauth_token']))
  end

  def logged_in?
    !session['oauth_token'].nil? && !oauth_token.expired?
  end

  def auth_url
    @auth_url ||= @client.auth_code.authorize_url(
      :redirect_uri => callback_url,
      :scope => 'osf.full_read',
      :response_type => 'code',
      :state => 'iuasdhf734t9hiwlf7'
    )
  end

  def check_logged_in
    redirect_to oauth_auth_url unless logged_in?
  end

  def detail_route project_id
    "/osf_api/detail/#{project_id}"
  end

  def import_route project_id
    "/osf_api/import/#{project_id}"
  end
end

