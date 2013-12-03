class CreateSeeVoRequests < ActiveRecord::Migration
  def self.up
    create_table :see_vo_requests do |t|
      t.column :person_id, :integer, :null => false
      t.column :accepted_aup, :integer, :null => false, :default => 0
      t.column :created_at, :timestamp, :null => false
    end
  end

  def self.down
    drop_table :see_vo_requests
  end
end
