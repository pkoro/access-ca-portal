class CreateRaStaffMemberships < ActiveRecord::Migration
  def self.up
    create_table :ra_staff_memberships do |t|
      t.column :ra_id, :integer, :null => false, :default=>0
      t.column :member_id, :integer, :null => false, :default=>0
      t.column :role, :integer, :null => false, :default=>0
    end
    RaStaffMembership.create :ra_id => 1, :member_id => 35, :role => 1
  end

  def self.down
    drop_table :ra_staff_memberships
  end
end
