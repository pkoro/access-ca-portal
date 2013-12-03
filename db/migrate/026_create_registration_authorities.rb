class CreateRegistrationAuthorities < ActiveRecord::Migration
  def self.up
    create_table :registration_authorities do |t|
      t.column :description, :string, :null => false
    end
    RegistrationAuthority.create :description => "Catch-all RA in GridAUTH"
  end

  def self.down
    drop_table :registration_authorities
  end
end
