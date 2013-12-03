class CreateDistinguishedNames < ActiveRecord::Migration
  def self.up
    create_table :distinguished_names do |t|
      t.column :subject_dn, :string, :null => false
      t.column :created_at, :timestamp, :null => false
      t.column :person_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :distinguished_names
  end
end
