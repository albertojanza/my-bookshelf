class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :uid       # twitter and facebook id
      t.string    :provider   # Third party
      t.integer   :read_count, :default => 0
      t.integer   :reading_count, :default => 0
      t.integer   :influence_rate, :default => 0
      t.string    :link
      t.string    :name
      t.string    :username
      t.string    :first_name
      t.string    :last_name
      t.string    :token
      t.string    :expires
      t.string    :locale
      t.boolean   :fb_read_communication, :default => false
      t.boolean   :fb_reading_communication, :default => true 
      t.boolean   :fb_next_communication, :default => true
      t.boolean   :libroshelf_communications, :default => true
      t.timestamps
    end

    #add_index :users, :id, :name => 'i_user_pk', :unique => true

  end
end
