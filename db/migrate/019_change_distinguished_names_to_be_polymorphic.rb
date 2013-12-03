class ChangeDistinguishedNamesToBePolymorphic < ActiveRecord::Migration
  def self.up
    add_column :distinguished_names, :owner_type, :string
    rename_column :distinguished_names, :person_id, :owner_id
  end

  def self.down
    remove_column :distinguished_names, :owner_id
    remove_column :distinguished_names, :owner_type
    add_column :distinguished_names, :person_id, :integer
  end
end
