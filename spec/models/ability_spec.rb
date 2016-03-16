require 'spec_helper'
require 'cancan/matchers'
# idea taken from: hydra-head/hydra-access-controls/spec/unit/ability_spec.rb
# we just need to check the custom_permissions

describe Ability, type: :model do
  context "A non-admin user" do
    let (:user) {FactoryGirl.create(:user)}
    subject {Ability.new(user)}

    it { should_not be_able_to(:create, Role) }
    it { should_not be_able_to(:show, Role) }
    it { should_not be_able_to(:add_user, Role) }
    it { should_not be_able_to(:remove_user, Role) }
    it { should_not be_able_to(:index, Role) }

    it {should_not be_able_to(:index, DoiRequest)}
    it {should_not be_able_to(:pending, DoiRequest)}
    it {should_not be_able_to(:mint_doi, DoiRequest)}
    it {should_not be_able_to(:view_doi, DoiRequest)}
    it {should_not be_able_to(:mint_all, DoiRequest)}
  end


  context "An admin user" do
    let (:admin) {FactoryGirl.create(:admin)}
    subject {Ability.new(admin)}

    it { should be_able_to(:create, Role) }
    it { should be_able_to(:show, Role) }
    it { should be_able_to(:add_user, Role) }
    it { should be_able_to(:remove_user, Role) }
    it { should be_able_to(:index, Role) }

    it {should be_able_to(:index, DoiRequest)}
    it {should be_able_to(:pending, DoiRequest)}
    it {should be_able_to(:mint_doi, DoiRequest)}
    it {should be_able_to(:view_doi, DoiRequest)}
    it {should be_able_to(:mint_all, DoiRequest)}
  end
end
