require "spec_helper"

RSpec.describe "publishables/index" do
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

  it "renders publishables index page with one publishable" do
    assign(:publishables, [collection])
    render
    expect(rendered).to render_template(:index)
  end
end
