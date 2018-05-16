class CreateReversedVats  < ActiveRecord::Migration
  def change
    create_table :reversed_vats do |t|
      t.string   :name
      t.datetime :vat_from
      t.datetime :vat_to
      t.string   :state
      t.datetime :calculated_at
      t.datetime :reported_at
      t.datetime :deadline
      t.integer  :accounting_period_id
      t.integer  :organization_id

      t.timestamps
    end
  end
end
