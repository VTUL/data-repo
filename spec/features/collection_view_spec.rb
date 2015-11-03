RSpec.describe 'collection view page', :type => :feature do

  let(:user) {FactoryGirl.create(:user)}
  let(:collection) do
    c = FactoryGirl.build(:collection)
    c.apply_depositor_metadata(user.user_key)
    c.save
    c
  end

  before do
    sign_in user
  end

  it 'allows user to edit a collection from the collection view' do
    visit '/collections/' + collection.id
    click_link "Edit"
    fill_in "Title", with: "Edited Title"
    click_button "update_submit"
    expect(page).to have_content "Edited Title"
  end

  it 'allows user to request doi for the collection' do
    pending "this feature has been removed!"
    visit '/collections/' + collection.id
    click_button "Request DOI"
    expect(page).to have_content "DOI request is pending..."
  end

end
