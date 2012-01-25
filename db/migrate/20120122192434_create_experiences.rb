class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.string :review, :default => nil
      t.time :started_at, :default => nil
      t.time :finised_at, :default => nil
      t.integer :user_id
      t.integer :adventure_id

      t.timestamps
    end
  end
end
