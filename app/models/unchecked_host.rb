class UncheckedHost < ActiveRecord::Base
  require 'resolv'
  set_table_name "hosts"
  validates_presence_of   :fqdn,
                          :message => "^ Η FQDN διεύθυνση δεν πρέπει να είναι κενή"
  validates_uniqueness_of :fqdn,
                          :message => "^ Η FQDN διεύθυνση χρησιμοποιείται ήδη.  Αν επιθυμείτε να αναλάβετε την διαχείρηση του θα πρέπει να επικοινωνήστε με την <a href='mailto:support@grid.auth.gr?subject=Αίτηση αλλαγής διαχειρηστή διακομιστή&body=Θέλω να αναλάβω την διαχείρηση του διακομιστή'>ομάδα υποστήριξης</a>"
  validates_length_of     :fqdn,
                          :maximum => 254,
                          :message => "^ Το μέγιστο μεγεθος της καταχώρησης για το κάθε πεδίο είναι 254 χαρακτήρες"
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
