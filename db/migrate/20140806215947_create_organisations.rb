class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :address
      t.string :zip
      t.string :city
      t.string :vat_number
      t.string :bankgiro
      t.string :postgiro
      t.string :plusgiro

      t.timestamps
    end
  end
end
