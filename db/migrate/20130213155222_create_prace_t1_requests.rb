class CreatePraceT1Requests < ActiveRecord::Migration
  def self.up
    create_table :prace_t1_requests do |t|
      t.column :person_id, :integer, :null => false
      t.column :accepted_aup, :integer, :null => false, :default => 0
      t.column :created_at, :timestamp, :null => false\
    end
  end

  def self.down
    drop_table :prace_t1_requests
  end
end
