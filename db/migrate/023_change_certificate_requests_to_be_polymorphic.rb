class ChangeCertificateRequestsToBePolymorphic < ActiveRecord::Migration
  def self.up
    add_column :certificate_requests, :owner_type, :string, :null => false, :default => "Person"
    rename_column :certificate_requests, :person_id, :owner_id
  end

  def self.down
    rename_column :certificate_requests, :owner_id, :person_id
    remove_column :certificate_requests, :owner_type
  end
end
