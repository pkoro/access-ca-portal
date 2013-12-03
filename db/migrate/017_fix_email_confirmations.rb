class FixEmailConfirmations < ActiveRecord::Migration
  def self.up
    add_column :email_confirmations, :confirmed_on, :timestamp
    add_column :email_confirmations, :created_at, :timestamp, :null => false, :default=> Time.now
    remove_column :email_confirmations, :last_confirmed_on
  end

  def self.down
    remove_column :email_confirmations, :confirmed_on 
    remove_column :email_confirmations, :created_at
    add_column :email_confirmations, :last_confirmed_on, :timestamp
  end
end
