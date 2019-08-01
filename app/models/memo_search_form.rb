class MemoSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :keyword, :string, default: ''
  attribute :with_title, :boolean, default: true
  attribute :with_content, :boolean, default: true
  attribute :with_tag, :boolean, default: true
  attribute :order, :string, default: ''

  ORDER_TITLE_ASC       = 1
  ORDER_TITLE_DESC      = 2
  ORDER_UPDATED_AT_ASC  = 3
  ORDER_UPDATED_AT_DESC = 4

  ORDER = {
    ORDER_TITLE_ASC => 'memos.title asc',
    ORDER_TITLE_DESC => 'memos.title desc',
    ORDER_UPDATED_AT_ASC => 'memos.updated_at asc',
    ORDER_UPDATED_AT_DESC => 'memos.updated_at desc'
  }.freeze

  def search(user_id)
    memos = Memo.user_memo(user_id)

    if keyword.present?
      if with_tag
        memos = memos.joins_tags if with_tag
        memos.distinct!
      end

      memos.where!(where_cond, { keyword: "%#{keyword}%" })
    end

    memos.tap do |m|
      m.order!(order_cond) if order_cond
    end
  end

  private

    def where_cond
      [].tap { |cond|
        cond << 'memos.title like :keyword' if with_title
        cond << 'memos.text_content like :keyword' if with_content
        cond << 'tags.name like :keyword' if with_tag
      }.join(' or ')
    end

    # パラメータからソート順を判定
    # デフォルトは作成日時の降順
    def order_cond
      ORDER[order.to_i] || 'created_at desc'
    end
end
