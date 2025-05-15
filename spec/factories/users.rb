FactoryBot.define do
    factory :user do
      sequence(:email) { |n| "user#{n}@example.com" }
      password { "password" }
      password_confirmation { "password" }
      approved { false }
      role { "trader" }
    end
  end
  