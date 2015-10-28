require 'rails_helper'

RSpec.describe DoiRequest, type: :model do
  let(:doi_request) {FactoryGirl.build(:doi_request)}

  it "can be created with asset_id" do
    expect{doi_request.save}.to change {DoiRequest.count}.by(1)
  end

  it "cannot have duplicate asset_id" do
    expect{2.times {doi_request.save}}.to change {DoiRequest.count}.by(1)
  end

  it "can be deleted after saving" do
    doi_request.save
    expect{doi_request.delete}.to change {DoiRequest.count}.by(-1)
  end

end
