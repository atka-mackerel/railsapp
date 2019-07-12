class YoutubeSearchCondition < ApplicationRecord
  # enum order: I18n.t('enums.youtube_search_condition.order')
  enum order: {
    date: 'date',
    rating: 'rating',
    relevance: 'relevance',
    title: 'title',
    videoCount: 'videoCount',
    viewCount: 'viewCount'
  }

  def to_params
    new_params = {}
    # old_params = attributes.delete_if { |k, v| k == 'with_comment' || v.nil? || v.to_s.empty? }
    old_params = attributes.delete_if { |_k, v| v.nil? || v.to_s.empty? }
    old_params.each do |k, v|
      # (new_key = k.camelize)[0] = new_key.chr.downcase
      new_params[k.to_sym] = v.is_a?(Time) ? v.rfc3339 : v
      # new_params[new_key.to_sym] = v
    end
    new_params
  end
end
