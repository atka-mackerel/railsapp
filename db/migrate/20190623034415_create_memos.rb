class CreateMemos < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :login_id, null: false
      t.string :password_digest, null: false

      t.timestamps
      t.index :login_id, unique: true
    end

    create_table :memos do |t|
      t.string :title, null: false
      t.text :text_content
      t.text :draw_content
      t.text :search_keyword

      t.references :user, index: true, foreign_key: true

      t.timestamps
    end

    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps

      t.index %i[name], unique: true
    end

    create_table :memo_tags do |t|
      t.references :memo, index: true, foreign_key: true
      t.references :tag, index: true, foreign_key: true

      t.timestamps
    end
  end
end
