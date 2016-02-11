require 'spec_helper'

RSpec.describe 'users/index' do
  let(:user1) {FactoryGirl.create(:user)}
  let(:user2) {FactoryGirl.create(:user)}
  let(:users) {[user1, user2]}

  before do
    allow(users).to receive(:limit_value).and_return(10)
    allow(users).to receive(:current_page).and_return(1)
    allow(users).to receive(:total_pages).and_return(1)
  end

  it "renders the users index page" do

    assign(:users, users)
    render
    expect(view).to render_template(:index)
  end
end

RSpec.describe 'users/show' do
  let(:user) {FactoryGirl.create(:user)}

  it "renders the users index page" do
    assign(:followers, [])
    assign(:following, [])
    assign(:trophies, [])
    assign(:events, [])
    assign(:user, user)
    render
    expect(view).to render_template(:show)
  end
end
