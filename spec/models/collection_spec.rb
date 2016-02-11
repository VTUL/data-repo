require 'spec_helper'

RSpec.describe Collection, type: :model do
  let(:user) {FactoryGirl.create(:user)}
  let(:collection) do
    c = FactoryGirl.build(:collection)
    c.apply_depositor_metadata(user.user_key)
    c
  end

  it "gets can be saved" do
    expect{collection.save}.to change{Collection.count}.by(1)
  end

  it "can be deleted" do
    collection.save
    expect{collection.delete}.to change{Collection.count}.by(-1)
  end

  it "has open visibility" do
    collection.save
    expect(collection.read_groups).to eq ['public']
  end

  it "does not allow a collection to be saved without a title" do
    collection.title = nil
    expect { collection.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  it "saves with a creator field" do
    collection[:creator] = ['test-creator@example.com']
    expect {collection.save}.to change{Collection.count}.by(1)
    expect(collection.creator).to eq ['test-creator@example.com']
  end
end
