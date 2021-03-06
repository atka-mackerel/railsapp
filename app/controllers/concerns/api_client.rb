# frozen_string_literal: true

require 'google/apis/youtube_v3'

module ApiClient
  class Youtube
    APPLICATION_VERSION       = '0.0.1'
    YOUTUBE_API_SERVICE_NAME  = 'youtube'
    YOUTUBE_API_VERSION       = 'v3'
    DEVELOPER_KEYS            = Rails.application.credentials.api[:youtube][:api_keys]

    API_SEARCH_LIST           = 'youtubeSearchList'
    API_COMMENT_THREADS       = 'youtubeCommentThreads'

    def initialize
      @client = Google::Apis::YoutubeV3::YouTubeService.new
      @client.key = api_key
    end

    def api_key
      DEVELOPER_KEYS.rotate!(1)
      DEVELOPER_KEYS.first
    end

    def search_list(parameters)
      parameters = parameters.merge(
        type: 'video',
        fields: 'nextPageToken,pageInfo(totalResults,resultsPerPage),' \
                'items(id/videoId,snippet(publishedAt,title,description,thumbnails/default/url))'
      )

      api_call do
        res = @client.list_searches('snippet', parameters)
        res.items.any? ? res : nil
      end
    end

    def comment_threads(parameters)
      parameters = {
        max_results: 50,
        fields: 'nextPageToken,' \
                'pageInfo(totalResults,resultsPerPage),' \
                'items' \
                '(id,snippet/topLevelComment/snippet' \
                '(authorDisplayName,authorProfileImageUrl,textOriginal,publishedAt,updatedAt),' \
                'replies/comments/snippet' \
                '(authorDisplayName,authorProfileImageUrl,textOriginal,publishedAt,updatedAt))'
      }.merge!(parameters).symbolize_keys!
      # pp parameters

      api_call do
        add_accessor(Google::Apis::YoutubeV3::ListCommentThreadsResponse, :videos)
        
        @client.list_comment_threads(
          'id,snippet,replies',
          parameters
        ).tap { |res| res.videos = videos(id: parameters[:video_id]) }
      end
    end

    def videos(parameters)
      parameters = parameters.merge(
        fields: 'items/statistics/commentCount'
      )

      api_call do
        @client.list_videos('statistics', parameters)
      end
    end

    def search_with_comments(with_comment, parameters)
      search_response = search_list(parameters)
      return search_response if search_response.errors || !with_comment

      add_accessor(Google::Apis::YoutubeV3::SearchResult, :comment_threads)

      search_response.items.each do |item|
        item.comment_threads = comment_threads(
          video_id: item.id.video_id
        )
      end

      search_response
    end

    def add_accessor(cls, method_name)
      return if cls.method_defined?(method_name)

      cls.class_exec { attr_accessor method_name }
    end

    def body_to_h(error_body)
      JSON.parse(error_body, symbolize_names: true)
    end

    def api_call
      result = yield
      if result
        ApiResult.new(data: result, errors: nil)
      else
        ApiResult.new(data: nil, errors: [{ reason: :noResults }])
      end
    rescue Google::Apis::Error => e
      ApiResult.new(data: nil, errors: body_to_h(e.body)[:error][:errors])
    end
  end

  class ApiResult
    attr_reader :data, :errors

    def initialize(data:, errors:)
      @data = data
      @errors = handle_error(errors)
    end

    def method_missing(method_name, *args, &block)
      return super if @data.nil?

      @data.send(method_name, *args, &block) if @data.respond_to?(method_name)
    end

    def respond_to_missing?(method, _include_private = false)
      @data.respond_to?(method)
    end

    private

      def handle_error(errors)
        @messages = I18n.t('errors.api.youtube')
        errors&.map do |item|
          @messages[item[:reason]&.intern] || @messages[:unexpected]
        end
      end
  end
end
