class CreateTaxTableRows  < ActiveRecord::Migration
  def change
    create_table :tax_table_rows do |t|
      t.string   :calculation
      t.integer  :from_wage
      t.integer  :to_wage
      t.integer  :column_1
      t.integer  :column_2
      t.integer  :column_3
      t.integer  :column_4
      t.integer  :column_5
      t.integer  :column_6
      t.integer  :organization_id
      t.integer  :tax_table_id

      t.timestamps
    end
  end
end
