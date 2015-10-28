RSpec.describe 'home page', :type => :feature do

  let(:user) {FactoryGirl.create(:user)}

  before do
    sign_in user
  end

  it 'shows the users name on the Dashboard' do
    visit '/dashboard'
    expect(page).to have_content('My Dashboard')
    # page.should have_content('VTechData')
  end

end
