require 'spec_helper'

describe 'searching' do
  let!(:file) { FactoryGirl.create(:public_file, title: ["Toothbrush"], description: ["blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah"]) }

  context "as a public user" do
    it "finds the file and have a gallery" do
      visit '/'
      fill_in "search-field-header", with: "Toothbrush"
      click_button "search-submit-header"
      expect(page).to have_content "1 entry found"
      within "#search-results" do
        expect(page).to have_content "Toothbrush"
      end

      click_link "Gallery"
      expect(page).to have_content "You searched for: Toothbrush"
      within "#documents" do
        expect(page).to have_content "Toothbrush"
      end
    end

    it "should truncate description" do
      visit '/'
      fill_in "search-field-header", with: "Toothbrush"
      click_button "search-submit-header"
      within "#search-results" do
        expect(page).to have_content "blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah bl..."
      end
    end

    it "does not display search options for dashboard files" do
      visit "/"
      within(".input-group-btn") do
        expect(page).to_not have_content("My Files")
        expect(page).to_not have_content("My Collections")
        expect(page).to_not have_content("My Shares")
      end
    end
  end
end
