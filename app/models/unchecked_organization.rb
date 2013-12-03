class UncheckedOrganization < ActiveRecord::Base
  set_table_name "organizations"
  has_many :unchecked_people
end