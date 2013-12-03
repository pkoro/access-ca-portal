class RaStaffMembership < ActiveRecord::Base
#  set_table_name "ra_staff_memberships"
  belongs_to :member,
             :class_name => "Person",
             :foreign_key => "member_id"
  belongs_to :registration_authority,
             :foreign_key => "ra_id"
end
