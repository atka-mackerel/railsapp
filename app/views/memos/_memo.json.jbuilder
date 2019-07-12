json.extract! memo, :id, :title, :text_content, :draw_content, :search_keyword, :created_at, :updated_at
json.url memo_url(memo, format: :json)
