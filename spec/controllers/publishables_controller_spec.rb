require 'spec_helper'

RSpec.describe PublishablesController, type: :controller do
  render_views
  let(:user) {FactoryGirl.create(:user)}

  describe "#index"  do
    before do
      sign_in user
    end

    let(:collection) do
      f = FactoryGirl.create(:generic_file)
      c = FactoryGirl.build(:collection)
      c.apply_depositor_metadata user.user_key
      c.member_ids = [f.id]
      c.save
      c
    end

    it "shows collections with files and without doi requests" do
      collections = [collection]
      get :index
      expect(assigns[:publishables]).to eq collections
    end
  end
end
