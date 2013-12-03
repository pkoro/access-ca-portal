class AddVersionsForPeople < ActiveRecord::Migration
  def self.up
    Person.create_versioned_table
  end

  def self.down
    Person.drop_versioned_table
  end
end
