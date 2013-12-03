class CreateScientificFields < ActiveRecord::Migration
  def self.up
    create_table :scientific_fields do |t|
      t.column :description, :string
    end
    add_column :people, :scientific_field_id, :integer
    add_column :person_versions, :scientific_field_id, :integer

    ScientificField.create :description => "Άλλο"
    ScientificField.create :description => "Αστροφυσική και σωματιδιακή αστροφυσική"
    ScientificField.create :description => "Εφαρμογές βιοϊατρικής και βιοπληροφορικής"
    ScientificField.create :description => "Υπολογιστική Χημεία"
    ScientificField.create :description => "Γεωπιστήμες"
    ScientificField.create :description => "Οικονομία"
    ScientificField.create :description => "Σύντηξη"
    ScientificField.create :description => "Γεωφυσική"
    ScientificField.create :description => "Φυσική υψηλών ενεργειών"
    ScientificField.create :description => "Μηχανική"
    ScientificField.create :description => "Επιστήμη υπολογιστών"
    ScientificField.create :description => "Μαθηματικών"
  end

  def self.down
    remove_column :person_versions, :scientific_field_id
    remove_column :people, :scientific_field_id
    drop_table :scientific_fields
  end
end
