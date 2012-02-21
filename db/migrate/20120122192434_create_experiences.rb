class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.string :review, :default => nil
      t.time :started_at, :default => nil
      t.time :finished_at, :default => nil
      t.integer :user_id
      t.integer :recommender_id
      t.integer :evangelist_id
      t.integer :influencer_id
      t.integer :book_id
      t.integer :code,  :default => 0#0 - Read, 1 - reading, 2 - future reading, 3 - recommendation
      t.timestamps
    end
  end
end
