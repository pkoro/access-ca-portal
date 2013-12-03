class Organization < ActiveRecord::Base
  has_many :people
  has_many :hosts
  has_many :certificate_requests

  has_and_belongs_to_many :registration_authorities,
                          :join_table => "ra_organization_relations",
                          :foreign_key => "organization_id",
                          :association_foreign_key => "ra_id"

  def self.find_by_fulldomain(domain)
    arr = domain.split(/\./).reverse
    if arr[1] == "edu"
      organization = self.find_by_domain([arr[2],arr[1],arr[0]].join("."))
    elsif arr[0] == "eu" && ( arr[1] == "hp-see" or arr[1] == "stratuslab" )
      organization = self.find_by_domain("hellasgrid.gr")
    else
      organization = self.find_by_domain([arr[1],arr[0]].join("."))
    end
    organization
  end
end
