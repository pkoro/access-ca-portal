class AddedRaInCertificateRequests < ActiveRecord::Migration
  def self.up
    add_column :certificate_requests, :ra_subject_dn, :string
  end

  def self.down
    remove_column :certificate_requests, :ra_subject_dn
  end
end
