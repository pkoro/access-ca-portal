require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the record count" do
    assert_equal Person.find(:all).count, 10
  end
  
  test "new person" do
    Person.make
    assert_equal Person.find(:all).count, 11
  end
  
  test "destroy first person" do
    Person.destroy(:first)
    assert_equal Person.find(:all).count, 9    
  end
end
