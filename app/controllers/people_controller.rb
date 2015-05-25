class PeopleController < ApplicationController
  def new
    @action_title = "#{I18n.t "controllers.people.user_registration_form"}"
    scientific_fields = ScientificField.find(:all)
    organizations = Organization.find(:all,:order => "name_el ASC")
    render_comatose :page=>"person/new", :locals=>{:organizations=>organizations, :scientific_fields=>scientific_fields}, :layout => true
  end
end
