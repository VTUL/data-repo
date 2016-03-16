require "spec_helper"

RSpec.describe "static/agreement" do
  it "renders the agreement page" do
    render
    expect(view).to render_template(:agreement)
  end
end
