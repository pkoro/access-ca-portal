class CreateEmailConfirmations < ActiveRecord::Migration
  def self.up
     create_table :email_confirmations do |t|
        t.column :hash, :string, :null => false
        t.column :person_id,  :int
        t.column :last_confirmed_on, :timestamp
      end
  end

  def self.down
    drop_table :email_confirmations
  end
end
