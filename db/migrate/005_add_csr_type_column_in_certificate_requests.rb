class AddCsrTypeColumnInCertificateRequests < ActiveRecord::Migration
  def self.up
    add_column :certificate_requests, :type, :string
  end

  def self.down
    remove_column :certificate_requests, :type
  end
end
