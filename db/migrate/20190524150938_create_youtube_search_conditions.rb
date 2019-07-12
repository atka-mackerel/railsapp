class CreateYoutubeSearchConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :youtube_search_conditions do |t|
      t.string :user_id
      t.integer :seq_no
      t.string :channel_id
      t.string :video_id
      t.integer :max_results
      t.string :order
      t.string :q
      t.string :type
      t.datetime :published_after
      t.datetime :published_before
      t.boolean :with_comment

      t.timestamps
    end
  end
end
