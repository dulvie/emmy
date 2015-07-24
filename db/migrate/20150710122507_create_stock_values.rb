class CreateStockValues  < ActiveRecord::Migration
  def change
    create_table :stock_values do |t|
      t.datetime :value_date
      t.string   :name
      t.text     :comment
      t.integer  :value
      t.string   :state
      t.datetime :reported_at
      t.integer  :organization_id

      t.timestamps
    end
  end
end
