class AddVersionsForHosts < ActiveRecord::Migration
  def self.up
    Host.create_versioned_table
  end

  def self.down
    Host.drop_versioned_table
  end
end
