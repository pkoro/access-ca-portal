class EmailConfirmation < ActiveRecord::Base
  def self.find_last_active_by_hash(hash)
    find :first,
          :conditions => ["user_hash = ? and created_at > ?", hash, 7.days.ago],
          :order => "created_at DESC"
  end
end
