class CreateTaxTables  < ActiveRecord::Migration
  def change
    create_table :tax_tables do |t|
      t.string   :name
      t.integer  :year
      t.integer  :organization_id

      t.timestamps
    end
  end
end
