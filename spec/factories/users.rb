FactoryGirl.define do
  factory :user do
    provider 'cas'
    sequence(:uid) { |n| "test_user#{n}" }
    sequence(:email) { |n| "test_user#{n}@example.com" }

    factory :default_user do
      uid 'default_user'
      email 'default@example.com'
    end

    factory :admin do
      sequence(:uid) { |n| "test_admin#{n}" }
      sequence(:email) { |n| "test_admin#{n}@example.com" }

      before(:create) do |admin|
        admin_role = Role.find_or_create_by(name: 'admin')
        admin.roles << admin_role
        admin.group_list = 'admin'
      end
    end
  end
end

