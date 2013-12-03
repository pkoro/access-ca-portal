class AddEmailInRa < ActiveRecord::Migration
  def self.up
    add_column :registration_authorities, :email, :string, :default => ""
  end

  def self.down
    remove_column :registration_authorities, :email
  end
end
