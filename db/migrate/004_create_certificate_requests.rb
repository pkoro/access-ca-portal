class CreateCertificateRequests < ActiveRecord::Migration
  def self.up
    create_table :certificate_requests do |t|
      t.column :body, :string, :null => false
      t.column :created_at, :timestamp
      t.column :updated_at, :timestamp
      t.column :person_id, :integer, :null => false
      # pending, approved, signed, rejected
      t.column :status, :string, :null => false
      t.column :comments, :text
      t.column :uniqueid, :string
    end
  end

  def self.down
    drop_table :certificate_requests
  end
end
