module Features
  module SessionHelpers
    def sign_in(who = :user)
      # logout
      user = who.is_a?(User) ? who : FactoryGirl.create(:user)
      visit new_user_session_path
      fill_in "user_email", with: user.email
      fill_in "user_password", with: user.password
      click_button "Log in"
      expect(page).not_to have_text 'Invalid email or password.'
    end
  end
end
