class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :first_name, :string, :null => false, :default => ""
      t.column :last_name, :string, :null => false, :default => ""
      t.column :organization, :string, :null => false, :default => ""
      t.column :department, :string
      t.column :position, :string, :null => false, :default => ""
      t.column :email, :string, :null => false, :default => ""
      t.column :work_phone, :string, :null => false, :default => ""
      t.column :scientific_area, :string
    end
  end

  def self.down
    drop_table :people
  end
end
