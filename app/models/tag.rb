class Tag < ApplicationRecord
  has_many :memo_tags, dependent: :restrict_with_error
  has_many :memos, through: :memo_tags

  validates :name, presence: true, uniqueness: true
end
