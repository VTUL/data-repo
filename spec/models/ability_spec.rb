require 'spec_helper'
require 'cancan/matchers'
# idea taken from: hydra-head/hydra-access-controls/spec/unit/ability_spec.rb
# we just need to check the custom_permissions

describe Ability, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user)}
  let (:my_file) do
    GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(user)
      gf.read_groups = ["public"]
      gf.save!
    end
  end
  let (:my_file_with_doi) do
    GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(user)
      gf.read_groups = ["public"]
      gf.save!
    end
  end
  let (:my_collection) do
    Collection.new(title: "test collection").tap do |c|
      c.apply_depositor_metadata(user)
      c.save!
    end
  end
  let! (:my_collection_with_doi) do
    Collection.new(title: "collection with doi", identifier: ["doi:10.5072/FK2AB1C234"]).tap do |c|
      c.apply_depositor_metadata(user)
      c.member_ids = [my_file_with_doi.id]
      c.save!
    end
  end

  describe "a user with no roles" do
    subject { Ability.new(nil) }

    it { is_expected.not_to be_able_to(:create, Role) }
    it { is_expected.not_to be_able_to(:show, Role) }
    it { is_expected.not_to be_able_to(:add_user, Role) }
    it { is_expected.not_to be_able_to(:remove_user, Role) }
    it { is_expected.not_to be_able_to(:index, Role) }

    it {is_expected.not_to be_able_to(:index, DoiRequest)}
    it {is_expected.not_to be_able_to(:pending, DoiRequest)}
    it {is_expected.not_to be_able_to(:mint_doi, DoiRequest)}
    it {is_expected.not_to be_able_to(:view_doi, DoiRequest)}
    it {is_expected.not_to be_able_to(:mint_all, DoiRequest)}

    it { is_expected.not_to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:read, my_file)}
    it { is_expected.not_to be_able_to(:update, my_file) }
    it { is_expected.not_to be_able_to(:destroy, my_file) }

    it { is_expected.not_to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:read, my_collection)}
    it { is_expected.not_to be_able_to(:update, my_collection) }
    it { is_expected.not_to be_able_to(:destroy, my_collection) }
  end

  describe "a registered user who owns the collection" do
    subject { Ability.new(user) }
    it { is_expected.not_to be_able_to(:create, Role) }
    it { is_expected.not_to be_able_to(:show, Role) }
    it { is_expected.not_to be_able_to(:add_user, Role) }
    it { is_expected.not_to be_able_to(:remove_user, Role) }
    it { is_expected.not_to be_able_to(:index, Role) }

    it {is_expected.not_to be_able_to(:index, DoiRequest)}
    it {is_expected.not_to be_able_to(:pending, DoiRequest)}
    it {is_expected.not_to be_able_to(:mint_doi, DoiRequest)}
    it {is_expected.not_to be_able_to(:view_doi, DoiRequest)}
    it {is_expected.not_to be_able_to(:mint_all, DoiRequest)}

    it { is_expected.to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:read, my_collection) }
    it { is_expected.to be_able_to(:read, my_collection_with_doi) }
    it { is_expected.to be_able_to(:update, my_collection) }
    it { is_expected.not_to be_able_to(:update, my_collection_with_doi) }
    it { is_expected.to be_able_to(:destroy, my_collection) }
    it { is_expected.not_to be_able_to(:destroy, my_collection_with_doi) }

    it { is_expected.to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:read, my_file) }
    it { is_expected.to be_able_to(:read, my_file_with_doi) }
    it { is_expected.to be_able_to(:update, my_file) }
    it { is_expected.not_to be_able_to(:update, my_file_with_doi) }
    it { is_expected.to be_able_to(:destroy, my_file) }
    it { is_expected.not_to be_able_to(:destroy, my_file_with_doi) }
  end

  describe "a registered user who does not own the collection" do
    subject { Ability.new(user2) }
    it { is_expected.to be_able_to(:read, my_file) }
    it { is_expected.not_to be_able_to(:update, my_file) }
    it { is_expected.not_to be_able_to(:destroy, my_file) }
    it { is_expected.to be_able_to(:read, my_collection) }
    it { is_expected.not_to be_able_to(:update, my_collection) }
    it { is_expected.not_to be_able_to(:destroy, my_collection) }
  end

  describe "An admin user" do
    let (:admin) {FactoryGirl.create(:admin)}
    subject {Ability.new(admin)}

    it { is_expected.to be_able_to(:create, Role) }
    it { is_expected.to be_able_to(:show, Role) }
    it { is_expected.to be_able_to(:add_user, Role) }
    it { is_expected.to be_able_to(:remove_user, Role) }
    it { is_expected.to be_able_to(:index, Role) }

    it {is_expected.to be_able_to(:index, DoiRequest)}
    it {is_expected.to be_able_to(:pending, DoiRequest)}
    it {is_expected.to be_able_to(:mint_doi, DoiRequest)}
    it {is_expected.to be_able_to(:view_doi, DoiRequest)}
    it {is_expected.to be_able_to(:mint_all, DoiRequest)}

    it { is_expected.to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:read, my_collection_with_doi) }
    it { is_expected.to be_able_to(:update, my_collection_with_doi) }
    it { is_expected.to be_able_to(:destroy, my_collection_with_doi) }

    it { is_expected.to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:read, my_file_with_doi) }
    it { is_expected.to be_able_to(:update, my_file_with_doi) }
    it { is_expected.to be_able_to(:destroy, my_file_with_doi) }
  end
end
