class AddLastIdCheckInPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :last_id_check_by, :integer
    add_column :people, :last_id_check_on, :datetime
    add_column :person_versions, :last_id_check_by, :integer
    add_column :person_versions, :last_id_check_on, :datetime
  end

  def self.down
    remove_column :people, :last_id_check_by
    remove_column :people, :last_id_check_on
    remove_column :person_versions, :last_id_check_by
    remove_column :person_versions, :last_id_check_on
  end
end
