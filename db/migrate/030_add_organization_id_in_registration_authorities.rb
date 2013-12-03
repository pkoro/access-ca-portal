class AddOrganizationIdInRegistrationAuthorities < ActiveRecord::Migration
  def self.up
    add_column :registration_authorities, :organization_id, :integer, :null => "false"
    catch_all_ra = RegistrationAuthority.find(1)
    catch_all_ra.organization_id = 3
    catch_all_ra.save
  end

  def self.down
    remove_column :registration_authorities, :organization_id
  end
end
