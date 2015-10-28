require "rails_helper"

RSpec.xdescribe "collections/show" do
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

  it "renders collections show page" do
    assign(:collection, collection)
    render "collections/show"

    expect(rendered).to render_template(:show)
  end
end

RSpec.describe "collections/new" do
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

  it "renders collections new page" do
    assign(:collection, collection)
    assign(:form, Sufia::Forms::CollectionEditForm.new(collection))
    render
    expect(view).to render_template(:new)
  end
end
