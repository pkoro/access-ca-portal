class AddTimestamps < ActiveRecord::Migration
  def self.up
    add_column :people, :created_at, :timestamp
    add_column :people, :updated_at, :timestamp
  end

  def self.down
    remove_column :people, :created_at
    remove_column :people, :updated_at
  end
end
