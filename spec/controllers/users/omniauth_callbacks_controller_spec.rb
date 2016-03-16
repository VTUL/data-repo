require 'spec_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe '#cas' do
    let(:user) {FactoryGirl.create(:user)}

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    context 'for persistent user' do
      it 'should redirect to the dashboard' do
        allow(User).to receive(:from_cas).and_return(user)
        get :cas
        expect(response).to redirect_to('/dashboard')
      end
    end

    context 'for non persistent user' do
      it 'should redirect to new user registration page' do
        user.delete
        allow(User).to receive(:from_cas).and_return(user)
        get :cas
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
