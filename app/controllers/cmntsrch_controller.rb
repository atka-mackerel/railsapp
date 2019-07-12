# frozen_string_literal: true

class CmntsrchController < ApplicationController
  skip_before_action :login_required
  before_action :init_control, only: %i[search comments]

  def search
    @session_search_condition = if @next_page_token
                                  session[:search_condition].symbolize_keys!
                                else
                                  YoutubeSearchCondition.new(search_params).to_params
                                end
    @search_condition = @session_search_condition.reject {|k, _v| k == :with_comment}
    @search_condition[:page_token] = @next_page_token if @next_page_token

    @search_result = @api_client.search_with_comments(
      @session_search_condition[:with_comment],
      @search_condition
    )

    session[:search_condition] = @session_search_condition
    render :json, template: 'cmntsrch/search', status: :internal_server_error if @search_result.errors
  end

  def comments
    @search_condition = comments_params
    @comment_threads = @api_client.comment_threads(@search_condition)

    if @comment_threads.errors
      render :json, template: 'cmntsrch/_comments', status: :internal_server_error
    else
      render :json, template: 'cmntsrch/_comments'
    end
  end

  def index
    @search_condition = YoutubeSearchCondition.new
  end

  private

    def init_control
      @api_client = ApiClient::Youtube.new
      @next_page_token = params[:page_token]
    end

    def search_params
      params.require(:youtube_search_condition)
            .permit(
              :q,
              :video_id,
              :published_after,
              :published_before,
              :with_comment,
              :order
            )
    end

    def comments_params
      params.permit(
        :video_id,
        :page_token
      )
    end
end
