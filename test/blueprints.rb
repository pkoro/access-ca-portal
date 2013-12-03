require 'machinist/active_record'
require 'sham'

Sham.first_name_en { Faker::Name.first_name }
Sham.last_name_en { Faker::Name.last_name.capitalize }
Sham.first_name_el(:unique => false) { ["Χρήστος", "Γιώργος", "Κώστας", "Δημήτρης"].rand }
Sham.last_name_el(:unique => false) { ["Τριανταφυλλίδης", "Παπαδόπουλος"].rand }
Sham.work_phone { Faker.numerify(["210#######","2310######"].rand) }
Sham.email(:unique => true) { Faker::Internet.email }
Sham.department { Faker::Name.name }

Person.blueprint do
  first_name_en[1..254]
  last_name_en[1..254]
  first_name_el[1..254]
  last_name_el[1..254]
  work_phone[1..254]
  email
  department[1..254]
end
