# frozen_string_literal: true

FactoryBot.define do
  factory :memo do
    title         { 'メモタイトル' }
    text_content  { 'メモテキスト入力' }
    draw_content  { 'data:image/png;base64,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' }
    user_id       { 1 }
  end
end
