class UseIdInsteadDnInCertificateRequests < ActiveRecord::Migration
  def self.up
    remove_column :certificate_requests, :ra_subject_dn
    add_column :certificate_requests, :ra_id, :integer
  end

  def self.down
    add_column :certificate_requests, :ra_subject_dn, :string
    remove_column :certificate_requests, :ra_id
  end
end
