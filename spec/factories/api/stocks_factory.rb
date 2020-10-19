FactoryBot.define do
  factory :bearer do
    sequence(:name) { |n| "Bearer#{n}" }
  end

  factory :stock do
    sequence(:name) { |n| "Stock#{n}" }
    association :bearer
  end
end
