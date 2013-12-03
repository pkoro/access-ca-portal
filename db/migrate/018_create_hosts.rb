class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.column :admin_id, :integer, :null => false
      t.column :fqdn, :string, :null => false, :default => ""
      t.column :organization_id, :integer, :null => false
      t.column :created_at , :datetime
      t.column :updated_at , :datetime
      t.column :version, :integer
    end
  end

  def self.down
    drop_table :hosts
  end
end
