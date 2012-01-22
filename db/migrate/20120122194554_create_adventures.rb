class CreateAdventures < ActiveRecord::Migration
  def change
    create_table :adventures do |t|
      t.integer :experience_id
      t.integer :resource_id
      t.string :resource_type

      t.timestamps
    end
  end
end
