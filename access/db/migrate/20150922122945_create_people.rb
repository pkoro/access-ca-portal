class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :first_name_latin
      t.string :last_name_latin
      t.string :email
      t.boolean :verified, default: false, null: false
      t.string :verification_token
      t.string :phone_number
      t.string :department
      t.belongs_to :position, index: true, foreign_key: :position_id
      t.belongs_to :scientific_field, index: true, foreign_key: :scientific_field_id
      t.belongs_to :organization, index: true, foreign_key: :organization_id

      t.timestamps null: false
    end
  end
end
