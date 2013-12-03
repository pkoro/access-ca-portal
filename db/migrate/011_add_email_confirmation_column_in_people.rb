class AddEmailConfirmationColumnInPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :email_confirmation, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :people, :email_confirmation
  end
end
