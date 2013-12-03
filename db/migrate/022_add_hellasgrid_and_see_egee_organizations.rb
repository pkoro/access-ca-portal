class AddHellasgridAndSeeEgeeOrganizations < ActiveRecord::Migration
  def self.up
    Organization.create :name_el => "HellasGrid", :domain => "hellasgrid.gr"
    Organization.create :name_el => "EGEE-SEE", :domain => "egee-see.org"
  end

  def self.down
    execute "DELETE FROM organizations WHERE domain='hellasgrid.gr'"
    execute "DELETE FROM organizations WHERE domain='egee-see.org'"
  end
end
