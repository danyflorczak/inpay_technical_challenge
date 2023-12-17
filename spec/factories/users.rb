FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    provider { "Google" }
    uid { Faker::Number.number(digits: 10) }
    token { Faker::Crypto.md5 }
    refresh_token { Faker::Crypto.md5 }
  end
end
