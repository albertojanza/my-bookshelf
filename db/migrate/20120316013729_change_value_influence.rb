class ChangeValueInfluence < ActiveRecord::Migration
  def up
    change_table :experiences do |t|
      t.float :influence_rate, :default => 10
    end
  end

  def down
  end
end
