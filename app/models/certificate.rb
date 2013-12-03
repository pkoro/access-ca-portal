class Certificate < ActiveRecord::Base
  belongs_to  :owner, :polymorphic => true
  has_many    :alternative_names
              
  def self.find_not_accepted_certificate_by_uniqueid(uniqueid)
    find( :first, 
          :conditions => ["certificate_request_uniqueid = ? 
                          and status = 'not_accepted' and created_at > ?",
                                uniqueid, 30.days.ago])
                                
  end
  
  def self.find_new_certificate_for_person(person)
    find  :first, 
          :conditions => ["owner_id = ? and status = 'not_accepted", person.id],
          :order => "created_at DESC"
  end
end
