class CreateWagePeriods < ActiveRecord::Migration
  def change
    create_table :wage_periods do |t|
      t.string   :name
      t.datetime :wage_from
      t.datetime :wage_to
      t.datetime :payment_date
      t.datetime :deadline

      t.string   :state
      t.datetime :wage_calculated_at
      t.datetime :wage_reported_at
      t.datetime :wage_closed_at
      t.datetime :tax_calculated_at
      t.datetime :tax_reported_at
      t.datetime :tax_closed_at
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :supplier_id

      t.timestamps
    end
  end
end
