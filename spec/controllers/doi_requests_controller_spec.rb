require 'spec_helper'

RSpec.describe DoiRequestsController, type: :controller do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    let(:doi_request) {FactoryGirl.create(:doi_request)}

    context "for normal users" do
      before {sign_in user}

      it 'should redirect' do
        get :index
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it 'should render index for admin users' do
        get :index
        expect(assigns[:doi_requests]).to eq [doi_request]
      end
    end

  end

  describe '#pending' do
    let(:doi_request) {FactoryGirl.create(:doi_request)}

    context "for normal users" do
      before {sign_in user}
      it 'should redirect' do
        get :pending
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      it 'should render pending doi requests for admin users' do
        get :pending
        expect(assigns[:doi_requests]).to eq [doi_request]
      end
    end
  end

  describe '#create' do
    let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

    before(:example) do
      sign_in admin
    end

    it "creates a Doi Request" do
      expect do
        post :create, asset_id: collection.id, asset_type: "Collection"
      end.to change { DoiRequest.count }.by(1)
    end

    it "successfully redirects to the collection show page" do
      post :create, asset_id: collection.id, asset_type: "Collection"
      expect(assigns(:asset).identifier).to include('doi:pending')
      expect(response).to redirect_to('/collections/' + collection.id)
    end
  end

  describe "#mint" do
    let(:doi_request) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    context "for normal users" do
      before {sign_in user}
      it "should redirect" do
        patch :mint_doi, id: doi_request
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      let (:doi_job) {double("assign doi job")}
      it "should crate a sufia job queue for doi_request" do
        allow(AssignDoiJob).to receive(:new).and_return(:doi_job)
        expect(Sufia.queue).to receive(:push).once
        patch :mint_doi, id: doi_request
      end
    end
  end

  describe '#view_doi' do
    let(:minted_doi) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_minted_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    context "for normal users" do
      before {sign_in user}
      it "should redirect" do
        get :view_doi, id: minted_doi
        expect(response).not_to have_http_status(200)
      end
    end

    context "for admin users" do
      before {sign_in admin}
      let (:ezid_doi) { FactoryGirl.create(:identifier) }
      it "should show the doi request" do
        allow(Ezid::Identifier).to receive(:find).and_return(:ezid_doi)
        get :view_doi, id: minted_doi
        expect(response).to be_successful
        expect(assigns[:doi_request]).to eq minted_doi
      end
    end
  end

  describe '#mint_all' do
    before {sign_in admin}

    let(:pending_doi) do
      c = FactoryGirl.create(:collection, :with_default_user, :with_pending_doi)
      DoiRequest.find_by_asset_id(c.id)
    end

    let(:pending_dois) {[pending_doi]}

    let(:doi_job) { double('assign doi job') }

    it "should assign jobs for minting dois" do
      allow(AssignDoiJob).to receive(:new).with(pending_doi.id, "http://test.host").and_return(doi_job)
      expect(Sufia.queue).to receive(:push).with(doi_job).once
      get :mint_all, doi_requests_checkbox: pending_dois
    end
  end
end
