class MemoSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :keyword, :string, default: ''
  attribute :with_title, :boolean, default: true
  attribute :with_content, :boolean, default: true
  attribute :with_tag, :boolean, default: true

  def search(user_id)
    memos = Memo.user_memo(user_id)

    if keyword.present?
      if with_tag
        memos = memos.joins_tags if with_tag
        memos = memos.distinct
      end
      memos = memos.where(condition, { keyword: "%#{keyword}%" })
    end

    memos
  end

  def condition
    cond = []
    cond << 'memos.title like :keyword' if with_title
    cond << 'memos.text_content like :keyword' if with_content
    cond << 'tags.name like :keyword' if with_tag
    cond.join(' or ')
  end
end
