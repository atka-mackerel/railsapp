json.apiName ApiClient::Youtube::API_COMMENT_THREADS
json.error @comment_threads.errors
if !@comment_threads.errors
  json.pageInfo do
    page_info = @comment_threads.page_info
    json.totalResults page_info.total_results
    json.resultsPerPage page_info.results_per_page
  end
  if @comment_threads.next_page_token
    json.nextPageToken @comment_threads.next_page_token
  else
    json.nextPageToken ''
  end
  json.commentCount @comment_threads.videos.items[0].statistics.comment_count
  json.items do
    json.array!(@comment_threads.items) do |comment_thread|
      json.id comment_thread.id
      top_level_comment = comment_thread.snippet.top_level_comment.snippet
      json.author top_level_comment.author_display_name
      json.profileImageUrl top_level_comment.author_profile_image_url
      json.text top_level_comment.text_original
      json.updatedAt top_level_comment.updated_at
      json.replies do
        json.items do
          replies = comment_thread.replies
          json.array!(replies ? replies.comments : []) do |reply|
            reply = reply.snippet
            json.author reply.author_display_name
            json.profileImageUrl reply.author_profile_image_url
            json.text reply.text_original
            json.updatedAt reply.updated_at
          end
        end
      end
    end
  end
else
  json.nextPageToken ''
  json.items { json.array!([]) }
  json.pageInfo do
    json.totalResults 0
    json.resultsPerPage 0
  end
  json.commentCount 0
end
