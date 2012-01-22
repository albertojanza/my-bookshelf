class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.string :review
      t.time :started_at
      t.time :finised_at
      t.integer :user_id
      t.integer :adventure_id

      t.timestamps
    end
  end
end
