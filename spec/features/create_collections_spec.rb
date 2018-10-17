require 'spec_helper'

RSpec.describe "Browse Dashboard", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe "Create collection without DOI" do
    before :each do
      OmniAuth.config.add_mock(:cas, { uid: user.uid })
      visit new_user_session_path
    end

    it "allows user to create a new collection without a DOI without identifier" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_unassigned"
      fill_in "Title", with: "Test Title"
      fill_in "Creator", with: "john.doe@example.com"
      fill_in "Contributor", with: "jane.doe@example.com"
      fill_in "Funding Info", with: "abc:def"
      begin
        click_button "Create Dataset"
      rescue Capybara::Poltergeist::JavascriptError => error
        puts "\nCaught JS error:"
        puts error.message
        #puts error.backtrace.inspect
      end
      expect(page).to have_content("Dataset was successfully created.")
      expect(page).to have_content("Test Title")
      expect(page).to have_content("abc: def")
    end
  end

  describe "Create collection with DOI" do
    before :each do
      OmniAuth.config.add_mock(:cas, { uid: admin.uid })
      visit new_user_session_path
    end

    it "allows user to create a new collection with direct DOI and identifier" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_assigned"
      click_button "Directly Fill Form"
      fill_in "collection_title", with: "Test Title"
      fill_in "Creator", with: "john.doe@example.com"
      fill_in "Contributor", with: "jane.doe@example.com"
      fill_in "Identifier", with: "123456"
      begin
        click_button "Create Dataset"
      rescue Capybara::Poltergeist::JavascriptError => error
        puts "\nCaught JS error:"
        puts error.message
        #puts error.backtrace.inspect
      end
      expect(page).to have_content("Dataset was successfully created.")
      expect(page).to have_content("Test Title")
    end

    it "allows user to create a new collection with datacite search" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_assigned"
      fill_in "Datacite Metadata Search:", with: "test"
      within "#datacite_search_form" do
        click_button "Search"
      end
      # need to sleep BEFORE clicking Import Metadata
      # otherwise click succeeds but effect does not take place
      sleep 10
      click_button "Import Metadata"
      begin
        click_button "Create Dataset"
      rescue Capybara::Poltergeist::JavascriptError => error
        puts "\nCaught JS error:"
        puts error.message
        #puts error.backtrace.inspect
      end
      expect(page).to have_content "Dataset was successfully created."
    end

    it "allows user to create a new collection with crossref search" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_unassigned"
      fill_in "Title", with: "Test Title"
      within "#crossref_search_form" do
        fill_in "query", with: "Test"
        click_button "Search CrossRef"
      end
      sleep 10
      click_button "Add DOI as related url"
      doi_link = find("#collection_related_url").value
      click_button "Create Dataset"
      expect(page).to have_content("Dataset was successfully created.")
      expect(page).to have_content(doi_link)
    end

    it "does not allow a user to create new collection without a title" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_unassigned"
      click_button "Create Dataset"
      within(".collection_title.form-group") do
        expect(page).to have_content "This field is required."
      end
    end

    it "does not allow user to enter wrongly formatted funder information" do
      visit "/dashboard"
      click_link "Organize"
      click_link "Create Dataset"
      choose "doi_status_unassigned"
      click_button "Create Dataset"
      fill_in "Title", with: "Test title"
      fill_in "Funding Info", with: "abcdef"
      within(".collection_funder.form-group") do
        expect(page).to have_content "Please enter correct funding Information format. (funder name: award number)"
      end
    end

  end
end
