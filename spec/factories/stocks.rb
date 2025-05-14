FactoryBot.define do
    factory :stock do
      sequence(:symbol)   { |n| "SYM#{n}" }
      company_name        { "Test Company" }
      current_price       { 100.0 }
    end
  end
  