FactoryGirl.define do
  # maybe this should have a trait "with :collection" that biulds the collection as well!
  factory :doi_request do
    asset_id 'mock-id'
    asset_type 'Collection'
  end
end
