# frozen_string_literal: true

FactoryBot.define do
  sequence(:id) { |n| n }

  factory :user do
    id
    name                  { 'テスト　太郎' }
    login_id              { "testuser#{id}" }
    password              { 'p@ssw0rd' }
    password_confirmation { 'p@ssw0rd' }
  end
end
