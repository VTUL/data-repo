require "rails_helper"

describe "DOI Operations", type: :feature, js: true do

  let(:admin) {FactoryGirl.create(:user, :with_admin_role)}
  let(:user) { FactoryGirl.create(:user) }
  let(:create_collection) do
    FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
  end

  describe "when the signed in user is not admin" do
    before do
      sign_in user
    end

    it "does not let non-admin users see doi request management links" do
      visit "/dashboard"
      click_link "select for additional menu options"
      expect(page).not_to have_content "Manage DOI Requests"
    end
  end

  describe "when these is no DOI requests present" do
    before do
      sign_in admin
    end

    it "let's an admin user see no doi requests" do
      visit "/dashboard"
      click_link "select for additional menu options"
      click_link "Manage DOI Requests"
      expect(page).to have_content "No doi requests found"
    end
  end

  describe "When there is pending doi requests" do
    before do
      sign_in admin
    end

    it "let's an admin user operate on doi requests" do
      create_collection
      visit "/dashboard"
      click_link "select for additional menu options"
      click_link "Manage DOI Requests"
      expect(page).to have_content "1 doi request found"
      click_button "Pending Requests"
      expect(page).to have_content "1 doi request found"
      click_link "Mint DOI"
      expect(page).to have_content "DOI has been minted successfully!"

      visit "/doi_requests/pending"
      expect(page).to have_content "No doi requests found"
      click_button "All Requests"
      expect(page).to have_content "1 doi request found"
      click_link "View DOI"
      expect(page).to have_content "DOI Information"
      expect(page).to have_content create_collection.title
      click_link "Back to DOI List"
      expect(page).to have_content "1 doi request found"
    end
  end

end
