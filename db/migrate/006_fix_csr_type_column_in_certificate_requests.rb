class FixCsrTypeColumnInCertificateRequests < ActiveRecord::Migration
  def self.up
    add_column :certificate_requests, :csrtype, :string
    remove_column :certificate_requests, :type
  end

  def self.down
    add_column :certificate_requests, :type, :string
    remove_column :certificate_requests, :csrtype
  end
end
