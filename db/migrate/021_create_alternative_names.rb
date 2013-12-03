class CreateAlternativeNames < ActiveRecord::Migration
  def self.up
    create_table :alternative_names do |t|
      t.column :alt_name_type, :string, :null => false
      t.column :alt_name_value, :string, :null => false
      t.column :certificate_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :alternative_names
  end
end
