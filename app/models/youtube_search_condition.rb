class YoutubeSearchCondition < ApplicationRecord
  enum order: {
    date: 'date',
    rating: 'rating',
    relevance: 'relevance',
    title: 'title',
    videoCount: 'videoCount',
    viewCount: 'viewCount'
  }

  # attributesをリクエスト用のパラメータに変換する
  # 空白、nilは除外する
  # Time型の属性はRFC3339形式に変換する
  def to_params
    {}.tap do |params|
      attributes.delete_if { |_k, v| v.blank? }
                .each { |k, v| params[k.to_sym] = v.is_a?(Time) ? v.rfc3339 : v }
    end
  end
end
