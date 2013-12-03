class FixedBodyTypeAddedOrganizationInCertificateRequests < ActiveRecord::Migration
  def self.up
    remove_column :certificate_requests, :body
    add_column :certificate_requests, :body, :text, :null => false, :default=>""
    add_column :certificate_requests, :organization_id, :integer, :null => false, :default=>0
  end

  def self.down
    remove_column :certificate_requests, :organization_id
    remove_column :certificate_requests, :body
    add_column :certificate_requests, :body, :string
  end
end
