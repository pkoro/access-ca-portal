class CreateHostAdministrationRequests < ActiveRecord::Migration
  def self.up
    create_table :host_administration_requests do |t|
      t.column "host_id", :integer, :default => 0, :null => false
      t.column "person_id", :integer, :default => 0, :null => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
  end

  def self.down
    drop_table :host_administration_requests
  end
end
