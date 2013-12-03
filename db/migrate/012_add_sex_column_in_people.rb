class AddSexColumnInPeople < ActiveRecord::Migration
  def self.up
    # 0: not specified
    # 1: female
    # 2: male
    add_column :people, :sex, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :people, :sex
  end
end
