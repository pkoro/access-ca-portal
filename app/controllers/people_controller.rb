class PeopleController < ApplicationController
  def new
    @action_title = "Φόρμα Εγγραφής Χρήστη"
    scientific_fields = ScientificField.find(:all)
    organizations = Organization.find(:all,:order => "name_el ASC")
    render_comatose :page=>"person/new", :locals=>{:organizations=>organizations, :scientific_fields=>scientific_fields}, :layout => true
  end
end
