require 'spec_helper'

describe UsersController, type: :controller  do
  routes { Sufia::Engine.routes }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    it 'allows admins access' do
      sign_in admin
      get :index
      expect(response).to be_success
      expect(response).to_not redirect_to(root_path)
    end

    it 'does not allow non-admins access' do
      sign_in user
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('Permission denied: cannot access this page.')
    end
  end

  describe '#show' do
    it 'allows admins access to access any profile' do
      sign_in admin

      get :show, id: admin.user_key
      expect(response).to be_success
      expect(response).to_not redirect_to(root_path)

      get :show, id: user.user_key
      expect(response).to be_success
      expect(response).to_not redirect_to(root_path)
    end

    it 'only allows non-admins access to their own profile.' do
      sign_in user

      get :show, id: user.user_key
      expect(response).to be_success
      expect(response).to_not redirect_to(root_path)

      get :show, id: admin.user_key
      expect(response).to redirect_to(@routes.url_helpers.profile_path(user.to_param))
      expect(flash[:alert]).to include('Permission denied: cannot access this page.')
    end
  end
end
