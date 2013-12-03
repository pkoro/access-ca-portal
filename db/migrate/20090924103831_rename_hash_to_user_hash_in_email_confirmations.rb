class RenameHashToUserHashInEmailConfirmations < ActiveRecord::Migration
  def self.up
    rename_column :email_confirmations, :hash, :user_hash
  end

  def self.down
    rename_column :email_confirmations, :user_hash, :hash
  end
end
