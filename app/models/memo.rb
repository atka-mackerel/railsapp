class Memo < ApplicationRecord
  belongs_to :user
  has_many :memo_tags, dependent: :destroy
  has_many :tags, through: :memo_tags

  validates_presence_of :title, on: %i[create update]

  scope :joins_tags, -> { left_joins(:tags).select('memos.*') }
  scope :user_memo, ->(user_id) { where('memos.user_id = ?', user_id) }

  CSV_ATTRIBUTES = %w[title text_content created_at updated_at].freeze

  def self.generate_csv
    bom = %w[EF BB BF].map { |e| e.hex.chr }.join
    CSV.generate(bom, headers: true) do |csv|
      csv << CSV_ATTRIBUTES
      all.each do |memo|
        csv << CSV_ATTRIBUTES.map { |attr| memo.send(attr) }
      end
    end
  end
end
