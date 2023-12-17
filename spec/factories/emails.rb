FactoryBot.define do
  factory :email do
    sender { Faker::Internet.email }
    subject { Faker::Lorem.sentence }
    email_date { Faker::Date.backward(days: 14) }
    email_datetime { Faker::Time.backward(days: 14, format: :default) }
    user
  end
end
