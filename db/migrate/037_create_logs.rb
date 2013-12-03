class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :registration_logs do |t|
      t.column :date, :timestamp
      t.column :from, :string
      t.column :person_id, :integer
      t.column :person_dn, :string
      t.column :action, :string
      t.column :data, :text
    end
  end

  def self.down
    drop_table :registration_logs
  end
end
