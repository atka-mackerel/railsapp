json.apiName ApiClient::Youtube::API_SEARCH_LIST
json.errors @search_result.errors
unless @search_result.errors
  json.nextPageToken @search_result.data.next_page_token ? @search_result.next_page_token : ''
  json.pageInfo do
    page_info = @search_result.page_info
    json.totalResults page_info.total_results
    json.resultsPerPage page_info.results_per_page
  end
  json.items do
    json.array!(@search_result.items) do |item|
      json.videoId item.id.video_id
      json.title item.snippet.title
      json.description item.snippet.description
      json.publishedAt l(item.snippet.published_at, format: :long)
      json.thumbnail do
        json.url item.snippet.thumbnails.default.url
      end
      if @comment_threads = item.instance_variable_get(:@comment_threads)
        json.comments do
          json.partial! partial: 'comments'
        end
      else
        json.comments nil
      end
    end
  end
end
