class CreateRaOrganizationRelations < ActiveRecord::Migration
  def self.up
    create_table :ra_organization_relations, :id => false do |t|
      t.column :ra_id, :integer, :null => false, :default=>0
      t.column :organization_id, :integer, :null => false, :default=>0
    end
    Organization.find(:all).each {|o| RegistrationAuthority.find(1).organizations << o}
  end

  def self.down
    drop_table :ra_organization_relations
  end
end
