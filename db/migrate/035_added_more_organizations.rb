class AddedMoreOrganizations < ActiveRecord::Migration
  def self.up
    Organization.create :name_el => "Εθνικό Ίδρυμα Ερευνών", :domain => "eie.gr"
    Organization.create :name_el => "Εθνικό Κέντρο Έρευνας & Τεχνολογικής Ανάπτυξης", :domain => "certh.gr"
    Organization.create :name_el => "Telecommunication Systems Research Institute", :domain => "tsi.gr"
  end

  def self.down
    execute "DELETE FROM organizations WHERE domain='eie.gr'"
    execute "DELETE FROM organizations WHERE domain='certh.gr'"
    execute "DELETE FROM organizations WHERE domain='tsi.gr'"
  end
end
