require 'spec_helper'

RSpec.describe PublishablesController, type: :controller do
  render_views
  let(:user) {FactoryGirl.create(:user)}

  describe "#index"  do
    let!(:collection) do
      f = FactoryGirl.create(:generic_file)
      c = FactoryGirl.build(:collection)
      c.apply_depositor_metadata user.user_key
      c.member_ids = [f.id]
      c.save
      c
    end

    before(:example) do
      sign_in user
      get :index
    end


    it "shows collections with files and without doi requests" do
      expect(response).to render_template('index')
      expect(assigns[:publishables]).to eq [collection]
      expect(response.body).to have_content("mock title")
      expect(response.body).to match(/Request DOI/)
    end
  end
end
