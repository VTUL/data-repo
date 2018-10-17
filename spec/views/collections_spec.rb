require "spec_helper"

RSpec.describe "collections/_show_descriptions.html.erb", type: :view do
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}
  let(:presenter) { Sufia::CollectionPresenter.new(collection) }

  it "renders collections show page" do
    assign(:presenter, presenter)
    assign(:collection, collection)
    collection.date_created = ['2000-01-01']
    render

    expect(rendered).to have_content 'Date Created'
    expect(rendered).to include('itemprop="dateCreated"')
    expect(rendered).to have_content '2000-01-01'
  end
end

RSpec.describe "collections/new" do
  let(:user) { FactoryGirl.create(:user) }
  let(:collection) {FactoryGirl.create(:collection, :with_default_user)}

  it "renders collections new page" do
    sign_in user
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
