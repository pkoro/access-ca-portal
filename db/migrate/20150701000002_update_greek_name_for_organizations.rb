class UpdateGreekNameForOrganizations < ActiveRecord::Migration
  def self.up
    Organization.find_each do |organization|
      case organization.name_el
      when "Ανωτέρα Εκκλησιαστική Σχολή Θεσσαλονίκης"
        organization.name_el = "Ανώτατη Εκκλησιαστική Ακαδημία Θεσσαλονίκης"
      when "ΑΣΠΑΙΤΕ"
        organization.name_el = "Ανώτατη Σχολή Παιδαγωγικής και Τεχνολογικής Εκπαίδευσης"
      when "Διεθνές κέντρο Δημόσιας Διοίκησης"
        organization.name_el = "Εθνικό Κέντρο Δημόσιας Διοίκησης και Αυτοδιοίκησης"
      when "ΕΚΕΒΕ Α. Φλέμιγκ"
        organization.name_el = "Ε.ΚΕ.Β.Ε. Αλέξανδρος Φλέμινγκ"
      when "ΙΑΣΑ"
        organization.name_el = "ΙΕΣΕ"
      when "Ίδρυμα Ιατροβιολογικής Έρευνας Ακαδημίας Αθηνών"
        organization.name_el = "Ίδρυμα Ιατροβιολογικών Ερευνών, Ακαδημίας Αθηνών"
      when "Ιδρυμα Τεχνολογίας  Ερευνας"
        organization.name_el = "Ιδρυμα Τεχνολογίας Ερευνας"
      when "Οργανισμός Αντισεισμικής Προστασίας"
        organization.name_el = "Οργανισμός Αντισεισμικού Σχεδιασμού και Προστασίας (Ο.Α.Σ.Π.)"
      when "ΤΕΙ Καβάλας"
        organization.name_el = "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Ανατολικής Μακεδονίας και Θράκης"
      when "ΤΕΙ Καλαμάτας"
        organization.name_el = "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Πελοποννήσου"
      when "ΤΕΙ Λαμίας"
        organization.name_el = "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Στερεάς Ελλάδας"
      when "ΤΕΙ Λάρισας"
        organization.name_el = "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Θεσσαλίας"
      when "ΤΕΙ Μεσσολογίου"
        organization.name_el = "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Δυτικής Ελλάδας"
      end
      organization.save!
    end
  end

  def self.down
    Organization.find_each do |organization|
      case organization.name_el
      when "Ανώτατη Εκκλησιαστική Ακαδημία Θεσσαλονίκης"
        organization.name_el = "Ανωτέρα Εκκλησιαστική Σχολή Θεσσαλονίκης"
      when "Ανώτατη Σχολή Παιδαγωγικής και Τεχνολογικής Εκπαίδευσης"
        organization.name_el = "ΑΣΠΑΙΤΕ"
      when "Εθνικό Κέντρο Δημόσιας Διοίκησης και Αυτοδιοίκησης"
        organization.name_el = "Διεθνές κέντρο Δημόσιας Διοίκησης"
      when "Ε.ΚΕ.Β.Ε. Αλέξανδρος Φλέμινγκ"
        organization.name_el = "ΕΚΕΒΕ Α. Φλέμιγκ"
      when "ΙΕΣΕ"
        organization.name_el = "ΙΑΣΑ"
      when "Ίδρυμα Ιατροβιολογικών Ερευνών, Ακαδημίας Αθηνών"
        organization.name_el = "Ίδρυμα Ιατροβιολογικής Έρευνας Ακαδημίας Αθηνών"
      when "Ιδρυμα Τεχνολογίας Ερευνας"
        organization.name_el = "Ιδρυμα Τεχνολογίας  Ερευνας"
      when "Οργανισμός Αντισεισμικού Σχεδιασμού και Προστασίας (Ο.Α.Σ.Π.)"
        organization.name_el = "Οργανισμός Αντισεισμικής Προστασίας"
      when "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Ανατολικής Μακεδονίας και Θράκης"
        organization.name_el = "ΤΕΙ Καβάλας"
      when "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Πελοποννήσου"
        organization.name_el = "ΤΕΙ Καλαμάτας" 
      when "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Στερεάς Ελλάδας"
        organization.name_el = "ΤΕΙ Λαμίας"
      when "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Θεσσαλίας"
        organization.name_el = "ΤΕΙ Λάρισας"
      when "Τεχνολογικό Εκπαιδευτικό Ίδρυμα Δυτικής Ελλάδας"
        organization.name_el = "ΤΕΙ Μεσσολογίου"
      end
      organization.save!
    end
  end
end
