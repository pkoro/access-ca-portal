class ChangePeopleToUseOrganizationsFromTheDatabase < ActiveRecord::Migration
  def self.up
    add_column :people, :organization_id, :integer
    remove_column :people, :organization
  end

  def self.down
    add_column :people, :organization, :string
    remove_column :people, :organization_id
  end
end
