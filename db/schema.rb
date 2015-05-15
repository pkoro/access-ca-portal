# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130213155222) do

  create_table "alternative_names", :force => true do |t|
    t.string  "alt_name_type",  :null => false
    t.string  "alt_name_value", :null => false
    t.integer "certificate_id", :null => false
  end

  create_table "certificate_requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id",                              :null => false
    t.string   "status",                                :null => false
    t.text     "comments"
    t.string   "uniqueid"
    t.string   "csrtype"
    t.string   "owner_type",      :default => "Person", :null => false
    t.integer  "requestor_id",    :default => 0,        :null => false
    t.integer  "ra_id"
    t.text     "body",            :default => "",       :null => false
    t.integer  "organization_id", :default => 0,        :null => false
  end

  create_table "certificates", :force => true do |t|
    t.text     "body"
    t.string   "status"
    t.string   "owner_type"
    t.string   "subject_dn"
    t.integer  "owner_id"
    t.string   "certificate_request_uniqueid"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "comatose_page_versions", :force => true do |t|
    t.integer  "comatose_page_id"
    t.integer  "version"
    t.integer  "parent_id"
    t.text     "full_path",                      :default => ""
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type",      :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                       :default => 0
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  create_table "comatose_pages", :force => true do |t|
    t.integer  "parent_id"
    t.text     "full_path",                 :default => ""
    t.string   "title"
    t.string   "slug"
    t.string   "keywords"
    t.text     "body"
    t.string   "filter_type", :limit => 25, :default => "Textile"
    t.string   "author"
    t.integer  "position",                  :default => 0
    t.integer  "version"
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  create_table "distinguished_names", :force => true do |t|
    t.string   "subject_dn", :null => false
    t.datetime "created_at", :null => false
    t.integer  "owner_id",   :null => false
    t.string   "owner_type"
  end

  create_table "email_confirmations", :force => true do |t|
    t.string   "user_hash",                                       :null => false
    t.integer  "person_id"
    t.datetime "confirmed_on"
    t.datetime "created_at",   :default => '2015-05-14 15:39:31', :null => false
  end

  create_table "host_administration_requests", :force => true do |t|
    t.integer  "host_id",    :default => 0, :null => false
    t.integer  "person_id",  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "host_versions", :force => true do |t|
    t.integer  "host_id"
    t.integer  "version"
    t.integer  "admin_id"
    t.string   "fqdn",            :default => ""
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.integer  "admin_id",                        :null => false
    t.string   "fqdn",            :default => "", :null => false
    t.integer  "organization_id",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
  end

  create_table "nwchem_vo_requests", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "accepted_aup", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string "name_el"
    t.string "name_en"
    t.string "domain"
  end

  create_table "people", :force => true do |t|
    t.string   "department"
    t.string   "position",            :default => "", :null => false
    t.string   "email",               :default => "", :null => false
    t.string   "work_phone",          :default => "", :null => false
    t.string   "scientific_area"
    t.string   "first_name_el",       :default => "", :null => false
    t.string   "first_name_en",       :default => "", :null => false
    t.string   "last_name_el",        :default => "", :null => false
    t.string   "last_name_en",        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "email_confirmation",  :default => 0,  :null => false
    t.integer  "sex",                 :default => 0,  :null => false
    t.integer  "version"
    t.integer  "last_id_check_by"
    t.datetime "last_id_check_on"
    t.integer  "scientific_field_id"
  end

  create_table "person_versions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "version"
    t.string   "department"
    t.string   "position",            :default => ""
    t.string   "email",               :default => ""
    t.string   "work_phone",          :default => ""
    t.string   "scientific_area"
    t.string   "first_name_el",       :default => ""
    t.string   "first_name_en",       :default => ""
    t.string   "last_name_el",        :default => ""
    t.string   "last_name_en",        :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "email_confirmation",  :default => 0
    t.integer  "sex",                 :default => 0
    t.integer  "last_id_check_by"
    t.datetime "last_id_check_on"
    t.integer  "scientific_field_id"
  end

  create_table "prace_t1_requests", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "accepted_aup", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
  end

  create_table "ra_organization_relations", :id => false, :force => true do |t|
    t.integer "ra_id",           :default => 0, :null => false
    t.integer "organization_id", :default => 0, :null => false
  end

  create_table "ra_staff_memberships", :force => true do |t|
    t.integer "ra_id",     :default => 0, :null => false
    t.integer "member_id", :default => 0, :null => false
    t.integer "role",      :default => 0, :null => false
  end

  create_table "registration_authorities", :force => true do |t|
    t.string  "description",                     :null => false
    t.integer "organization_id"
    t.string  "email",           :default => ""
  end

  create_table "registration_logs", :force => true do |t|
    t.datetime "date"
    t.string   "from"
    t.integer  "person_id"
    t.string   "person_dn"
    t.string   "action"
    t.text     "data"
  end

  create_table "scientific_fields", :force => true do |t|
    t.string "description"
  end

  create_table "see_vo_requests", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "accepted_aup", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
  end

  create_table "ui_requests", :force => true do |t|
    t.integer  "person_id",                     :null => false
    t.string   "user_interface",                :null => false
    t.integer  "accepted_aup",   :default => 0, :null => false
    t.datetime "created_at",                    :null => false
  end

end
