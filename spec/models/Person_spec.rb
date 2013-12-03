require File.dirname(__FILE__) + '/../spec_helper'

context "The Person model with fixtures loaded" do
  fixtures :people,:certificates,:distinguished_names,:organizations

  setup do
    # fixtures are setup before this
  end

  specify "should have a non-empty collection of people" do
    Person.find(:all).should_not_be_empty
  end

  specify "should have 45 records" do
    Person.should_have(45).records
  end

  specify "should have valid records" do
    Person.find(:all).each do |person|
      person.should_be_a_kind_of(Person)
      person.work_phone="2310123456"
      person.last_name_el="Επιθέτο"
      person.should_be_valid
      person.organization.should_not_be_nil
    end
  end
  
  specify "should have at least one certificate but at most one current" do
    Person.find(:all).each do |person|
      person.should_have_at_least(1).certificates
      person.should_have_at_most(1).current_certificate
    end
  end

  specify "should have at least one distinguished name" do
    Person.find(:all).each do |person|
      person.should_have_at_least(1).distinguished_name
    end
  end

  teardown do
    # fixtures are torn down after this
  end
end