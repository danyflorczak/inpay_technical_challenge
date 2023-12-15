FactoryBot.define do
  factory :email do
    sender { "MyString" }
    subject { "MyString" }
    email_date { "2023-12-15" }
    email_datetime { "2023-12-15 17:30:05" }
    user { nil }
  end
end
