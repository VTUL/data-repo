require "rails_helper"

RSpec.describe "contact_form/new" do
  it "renders the contact form" do
    assign(:contact_form, ContactForm.new)
    render
    expect(view).to render_template(:new)
  end
end
