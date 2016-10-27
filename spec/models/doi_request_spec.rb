require 'spec_helper'

RSpec.describe DoiRequest, type: :model do
  subject {FactoryGirl.build(:doi_request)}

  it "initially saves as a pending request" do
    subject.save
    expect(subject).not_to be_completed
  end

  it "saves as a Collection asset by default" do
    subject.save
    expect(subject).to be_collection
  end

  it "can be created with asset_id" do
    expect{subject.save}.to change {DoiRequest.count}.by(1)
  end

  it "can be completed with Ezid assigned doi" do
    subject.ezid_doi = "doi:10.5072/FK22B91G0V" 
    subject.save
    expect(subject).to be_completed
  end

  it "cannot have duplicate asset_id" do
    expect{2.times {subject.save}}.to change {DoiRequest.count}.by(1)
  end

  it "can be deleted after saving" do
    subject.save
    expect{subject.delete}.to change {DoiRequest.count}.by(-1)
  end

end
