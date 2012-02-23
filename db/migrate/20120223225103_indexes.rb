class Indexes < ActiveRecord::Migration
  def up
    add_index 'users','uid'
    add_index 'books','asin'
    add_index 'books','permalink'
    add_index 'experiences','recommender_id'
    add_index 'experiences','book_id'
    add_index 'experiences',['user_id','code']
  end

  def down
  end
end
