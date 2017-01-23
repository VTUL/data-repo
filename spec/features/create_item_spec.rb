# Generated via
#  `rails generate curation_concerns:work Item`
require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Item' do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit new_curation_concerns_item_path
      fill_in 'Title', with: 'Test Item'
      click_button 'Create Item'
      expect(page).to have_content 'Test Item'
    end
  end
end
