class ChangeCertificatesToBePolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :certificates, :cert_type, :owner_type
  end

  def self.down
    rename_column :certificates, :owner_type, :cert_type
  end
end
