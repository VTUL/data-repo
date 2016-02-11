require 'spec_helper'

RSpec.describe CollectionsController, type: :controller do
  render_views
  # https://github.com/rspec/rspec-rails recommends not using render_views
  # but need to do this for now as controller view tests are not working

  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#create' do
    routes { Hydra::Collections::Engine.routes }
    before do
      sign_in user
    end

    it "creates a collection without funder" do
      expect do
        post :create, collection: { title: "Mock VTechData Collection ", description: "The Description\r\n\r\nand more" }
      end.to change { Collection.count }.by(1)
    end

    it "creates a collection with funder" do
      expect do
        post :create, collection: { title: "Mock VTechData Collection", funder: ["abcd:1234", "zyx: 987"]}
      end.to change { Collection.count }.by(1)
      expect(assigns[:collection].funder).to match_array([
        "<funder><fundername>abcd</fundername><awardnumber>1234</awardnumber></funder>",
        "<funder><fundername>zyx</fundername><awardnumber> 987</awardnumber></funder>",
      ])
    end

    it "creates the corresponding doi request" do
      expect do
        post :create, {collection: { title: "Mock VTechData Collection" }, request_doi: "Yes"}
      end.to change { DoiRequest.count }.by(1)
      expect(assigns[:collection][:identifier]).to eq ['doi:pending']
      expect(DoiRequest.find_by_asset_id(assigns[:collection].id)).not_to be_nil
    end
  end

  describe "#update" do
    routes { Hydra::Collections::Engine.routes }
    before do
      sign_in user
    end

    # TODO?
  end

  describe "#datacite_search" do
    before do
      sign_in user
    end

    it "gives valid radio button when search returns match" do
      pending "fix ajax issue?"
      search_params = {q: "test", fl: "doi, creator, publisher, publicationYear, title", rows: 20, wt: "json", commit: "Search"}
      request.headers[:X_REQUESTED_WITH] = "XMLHttpRequest"
      get :datacite_search, search_params
      expect(response.status).to be 200
    end

    it "gives valid radio button when search does not return any match" do
      # TODO?
    end
  end

  describe "#crossref_search" do
    before do
      sign_in user
    end

    it "turns json to ruby object" do
      pending "figure out ajax fix?"
      post :crossref_search, results: '{"test":"test"}'
      expect(assigns[results]).to eq ({"test" => "test"})
    end
  end

  describe "#import_metadata" do
    before do
      sign_in user
    end

    it "replaces => with :" do
      pending "figure out ajax fix?"
      post :import_metadata, result: '{"test"=>"test"}'
      expect(assigns[result]).to eq '{"test":"test"}'
    end
  end

  describe "#ldap_search" do
    before do
      sign_in user
    end

    it "gives creators when search returns match" do
      get :ldap_search, label: "creator", name: "zhiwu xie"
      expect(assigns[:radio_name]).to eq "creator"
      expect(assigns[:results]).not_to be_empty
    end

    it "gives message when there is no match" do
      get :ldap_search, label: "creator", name: "@#thiswillnevermatch$%"
      expect(assigns[:results]).to be_empty
    end
  end

  describe "#add_files" do
    let(:file1) do
      f = FactoryGirl.build(:public_file)
      f.apply_depositor_metadata user.user_key
      f.save
      f
    end

    let(:file2) do
      f = FactoryGirl.build(:public_file)
      f.apply_depositor_metadata admin.user_key
      f.save
      f
    end

    context "for normal users" do
      before do
        sign_in user
      end

      let(:collection) do
        c = FactoryGirl.build(:collection)
        c.apply_depositor_metadata user.user_key
        c.save
        c
      end

      it "shows all files of the user" do
        files = [file1]
        get :add_files, id: collection
        expect(assigns[:collection]).to eq collection
        expect(assigns[:files].length).to eq files.length
        expect(assigns[:files][0].id).to eq files[0].id
      end
    end

    context "for admin users" do
      before do
        sign_in admin
      end

      let(:collection) do
        c = FactoryGirl.build(:collection)
        c.apply_depositor_metadata admin.user_key
        c.save
        c
      end

      it "shows all files of the user" do
        files = [file1, file2]
        get :add_files, id: collection
        expect(assigns[:collection]).to eq collection
        expect(assigns[:files].length).to eq files.length
        expect(assigns[:files].map{|f| f.id}).to include files[0].id
        expect(assigns[:files].map{|f| f.id}).to include files[1].id
      end
    end
  end
end
