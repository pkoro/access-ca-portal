
class CreateCertificates < ActiveRecord::Migration
  def self.up    
    create_table :certificates do |t|
      t.column :body, :text
      t.column :status, :string
      t.column :cert_type, :string
      t.column :subject_dn, :string
      t.column :cert_type, :string
      t.column :owner_id, :int
      t.column :certificate_request_uniqueid, :string
      t.column :created_at, :timestamp, :null => false
      t.column :updated_at, :timestamp, :null => false
    end
  end

  def self.down
    drop_table :certificates
  end
end

