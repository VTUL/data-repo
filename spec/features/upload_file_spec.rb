require "spec_helper"

RSpec.describe "Uploading files from the web form", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    OmniAuth.config.add_mock(:cas, { uid: user.uid })
    visit new_user_session_path
    click_link "Upload"
  end

  xit "has an ingest screen" do
    expect(page).to have_content 'Upload limits:'
    expect(page).to have_xpath '//input[@type="file"]'
  end

  it "allows me to upload a file and apply metadata", unless: ENV['TRAVIS'] do
    check "terms_of_service"
    attach_file "files[]", "spec/fixtures/vt-logo.png", visible: false
    click_button "main_upload_start"
    expect(page).to have_content "Describe Item(s)"
    fill_in "Keyword", with: "test"
    click_button "Save"
    expect(page).to have_content "My Files"
    expect(page).to have_content "vt-logo.png"
  end
end
