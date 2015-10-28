require "rails_helper"

describe "Browse Dashboard", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  it "allows me to upload file and apply metadata from the Dashboard link", unless: ENV['TRAVIS'] do
    visit "/dashboard"
    click_link "Upload"
    check "terms_of_service"
    page.attach_file "files[]", "spec/fixtures/vt-logo.png"
    click_button "main_upload_start"
    expect(page).to have_content "Apply Metadata"
    fill_in "Keyword", with: "test"
    click_button "Save"
    expect(page).to have_content "My Files"
    expect(page).to have_content "vt-logo.png"
  end
end
