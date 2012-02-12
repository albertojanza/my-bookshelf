# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120122195003) do

  create_table "books", :force => true do |t|
    t.string   "asin"
    t.integer  "experience_id"
    t.string   "permalink"
    t.string   "title"
    t.string   "author"
    t.string   "detail_page_url"
    t.string   "ean"
    t.string   "isbn"
    t.string   "number_of_pages"
    t.string   "product_group"
    t.string   "studio"
    t.string   "publisher"
    t.string   "publication_date"
    t.string   "medium_image"
    t.string   "tiny_image"
    t.string   "large_image"
    t.string   "thumbnail_image"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "experience_id"
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "experiences", :force => true do |t|
    t.string   "review"
    t.time     "started_at"
    t.time     "finised_at"
    t.integer  "user_id"
    t.integer  "recommender_id"
    t.integer  "book_id"
    t.integer  "code",           :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "provider"
    t.integer  "user_id"
    t.string   "link"
    t.string   "name"
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "token"
    t.string   "expires"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
