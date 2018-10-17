FactoryGirl.define do
  factory :collection do
    title 'mock title'

    trait :with_default_user do
      after(:build) do |collection|
        collection.apply_depositor_metadata FactoryGirl.create(:default_user)
      end
    end

    trait :with_pending_doi do
      after(:create) do |collection|
        DoiRequest.create(asset_id: collection.id, asset_type: "Collection")
        collection.update_attributes({:identifier => collection.identifier.to_a.push("doi:pending")})
      end
    end

    trait :with_minted_doi do
      after(:create) do |collection|
        doi_request = DoiRequest.create(asset_id: collection.id, asset_type: 'Collection')

        minted_doi = FactoryGirl.create(:identifier) 
        collection[:identifier].each_with_index {
          |id, idx| id == "doi:pending" ? collection[:identifier][idx] = minted_doi.id : id
        }
        doi_request.update_attributes({:ezid_doi => minted_doi.id})
        collection.update_attributes({:identifier => collection[:identifier]})
      end
    end
  end
end
