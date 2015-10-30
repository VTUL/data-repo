FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test-user#{n}@example.com" }
    password 'password'

    factory :default_user do
      email 'test@example.com'
    end

    trait :with_admin_role do
      after(:create) do |admin|
        # bad code! need to refactor!!!
        r = Role.find_by_name("admin")
        r ||= Role.create(name: 'admin')
        r.users << admin
      end

      factory :jill do
        email 'jilluser@example.com'
      end

      factory :archivist, aliases: [:user_with_fixtures] do
        email 'archivist1@example.com'
      end

      factory :curator do
        email 'curator1@example.com'
      end

    end
  end
end

