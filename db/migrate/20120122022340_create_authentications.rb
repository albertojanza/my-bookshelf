class CreateAuthentications < ActiveRecord::Migration
  def change

    create_table :authentications do |t|
      t.string    :uid       # twitter and facebook id
      t.string    :provider   # Third party
      t.integer   :user_id

      t.string    :token
      t.string    :expires

      t.string    :info

      t.timestamps



    end
    #add_index :authentications, :uid

  end
end
