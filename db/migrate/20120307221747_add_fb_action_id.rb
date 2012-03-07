class AddFbActionId < ActiveRecord::Migration
  def up
    change_table :experiences do |t|
      t.string :facebook_action_id
    end
  end

  def down
  end
end
