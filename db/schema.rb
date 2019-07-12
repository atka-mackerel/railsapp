# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_23_034415) do

  create_table "memo_tags", force: :cascade do |t|
    t.integer "memo_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_id"], name: "index_memo_tags_on_memo_id"
    t.index ["tag_id"], name: "index_memo_tags_on_tag_id"
  end

  create_table "memos", force: :cascade do |t|
    t.string "title", null: false
    t.text "text_content"
    t.text "draw_content"
    t.text "search_keyword"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "login_id", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
  end

  create_table "youtube_search_conditions", force: :cascade do |t|
    t.string "user_id"
    t.integer "seq_no"
    t.string "channel_id"
    t.string "video_id"
    t.integer "max_results"
    t.string "order"
    t.string "q"
    t.string "type"
    t.datetime "published_after"
    t.datetime "published_before"
    t.boolean "with_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
