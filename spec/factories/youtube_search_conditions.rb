# frozen_string_literal: true

FactoryBot.define do
  factory :youtube_search_condition do
    id                { nil }
    user_id           { nil }
    seq_no            { nil }
    channel_id        { nil }
    video_id          { nil }
    max_results       { nil }
    order             { nil }
    q                 { nil }
    type              { nil }
    published_after   { nil }
    published_before  { nil }
    with_comment      { nil }
  end
end
