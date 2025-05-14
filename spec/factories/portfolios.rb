# spec/factories/portfolios.rb
FactoryBot.define do
    factory :portfolio do
      # Associate to a user—FactoryBot will build one if you pass no user
      association :user
      cash_balance { 1000.0 }
    end
  end
  