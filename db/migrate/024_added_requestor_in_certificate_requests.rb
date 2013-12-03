class AddedRequestorInCertificateRequests < ActiveRecord::Migration
  def self.up
    add_column :certificate_requests, :requestor_id, :integer, :null => false, :default=>0
  end

  def self.down
    remove_column :certificate_requests, :requestor_id
  end
end
