require "spec_helper"

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

RSpec.describe "collections/add_files" do
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}
  let(:file) {FactoryGirl.create(:generic_file)}

  it "renders collections add-file page" do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(file).to receive(:title_or_label).and_return(file.filename)
    assign(:collection, collection)
    assign(:files, [file])
    render
    expect(view).to render_template(:add_files)
  end
end
