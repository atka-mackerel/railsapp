class Memo < ApplicationRecord
  belongs_to :user
  has_many :memo_tags, dependent: :destroy
  has_many :tags, through: :memo_tags

  validates_presence_of :title, on: %i[create update]

  scope :joins_tags, -> { left_joins(:tags).select('memos.*') }
  scope :user_memo, ->(user_id) { where('memos.user_id = ?', user_id) }
end
