require "spec_helper"

describe DatarepoHelper do
  describe "#link_to_user_or_facet" do
    before do
      allow(helper).to receive(:link_to) do |arg1, arg2|
        "user_link_#{arg1}_#{arg2}"
      end

      allow(helper).to receive(:link_to_facet) do |arg1, arg2|
        "facet_link_#{arg1}_#{arg2}"
      end
    end

    it "generates link to facet for non-existing user" do
      user = FactoryGirl.build(:user)
      expect(helper.link_to_user_or_facet(user.email,"field")).to eq "facet_link_#{user.email}_field"
    end

    it "generates link to user for existing user without display_name" do
      user = FactoryGirl.create(:user)
      expect(helper.link_to_user_or_facet(user.email,"field")).to eq "user_link_#{user.email}_#{sufia.profile_path(user)}"
    end

    it "generates link to user for existing user with display_name" do
      user = FactoryGirl.build(:user)
      user[:display_name] = "John Doe"
      user.save
      expect(helper.link_to_user_or_facet(user.email,"field")).to eq "user_link_John Doe_#{sufia.profile_path(user)}"
    end
  end

  describe "#link_to_user_or_field" do
    before do
      allow(helper).to receive(:link_to) do |arg1, arg2|
        "user_link_#{arg1}_#{arg2}"
      end

      allow(helper).to receive(:link_to_field) do |arg1, arg2|
        "field_link_#{arg1}_#{arg2}"
      end
    end

    it "generates link to field for non-existing user" do
      user = FactoryGirl.build(:user)
      expect(helper.link_to_user_or_field("field",user.email)).to eq "field_link_#{user.email}_field"
    end

    it "generates link to user for existing user without display_name" do
      user = FactoryGirl.create(:user)
      expect(helper.link_to_user_or_field(user.email,"field")).to eq "user_link_#{user.email}_#{sufia.profile_path(user)}"
    end

    it "generates link to user for existing user with display_name" do
      user = FactoryGirl.build(:user)
      user[:display_name] = "John Doe"
      user.save
      expect(helper.link_to_user_or_field(user.email,"field")).to eq "user_link_John Doe_#{sufia.profile_path(user)}"
    end
  end

  describe "#parse_funder" do
    it "can parse valid parser xml" do
      funder_xml = "<funder><fundername>test</fundername><awardnumber>1234</awardnumber></funder>"
      expect(helper.parse_funder(funder_xml)).to eq "test: 1234"
    end
  end

end
