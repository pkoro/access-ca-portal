class AddEnglishTranslationForNames < ActiveRecord::Migration
  def self.up
    remove_column :people, :first_name
    remove_column :people, :last_name
    add_column :people, :first_name_el, :string, :null => false, :default => ""
    add_column :people, :first_name_en, :string, :null => false, :default => ""
    add_column :people, :last_name_el, :string, :null => false, :default => ""
    add_column :people, :last_name_en, :string, :null => false, :default => ""
  end

  def self.down
    remove_column :people, :first_name_el
    remove_column :people, :first_name_en
    remove_column :people, :last_name_el
    remove_column :people, :last_name_en
    add_column :people, :first_name, :string, :default => ""
    add_column :people, :last_name, :string, :default => ""
  end
end
