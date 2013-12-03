class HostAdministrationRequest < ActiveRecord::Base
  belongs_to :host
  belongs_to :person
end
