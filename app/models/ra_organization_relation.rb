class RaOrganizationRelation < ActiveRecord::Base
  belongs_to :registration_authority,
             :foreign_key => "ra_id"
  belongs_to :organization  
end
