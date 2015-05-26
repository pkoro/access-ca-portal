class UncheckedHost < ActiveRecord::Base
  require 'resolv'
  set_table_name "hosts"
  validates_presence_of   :fqdn,
                          :message => "#{I18n.t "activerecord.errors.models.host.fqdn_not_empty"}"
  validates_uniqueness_of :fqdn,
                          :message => "#{I18n.t "activerecord.errors.models.host.fqdn_used"}"
  validates_length_of     :fqdn,
                          :maximum => 254,
                          :message => "#{I18n.t "activerecord.errors.models.host.max_length"}"
  belongs_to :organization
  belongs_to :admin,
             :class_name => "Person",
             :foreign_key => "admin_id"
  has_many :distinguished_names,
           :as => :owner
  has_one :certificate,
          :as => :owner,
          :conditions => "created_at > to_timestamp(#{Time.now.last_year.strftime("%Y-%m-%d")}) and status = 'valid'",
          :order => 'created_at DESC'

end
