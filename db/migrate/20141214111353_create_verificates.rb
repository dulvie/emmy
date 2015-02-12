class CreateVerificates < ActiveRecord::Migration
  def change
    create_table :verificates do |t|
      t.integer  :number
      t.string   :state
      t.datetime :posting_date
      t.string   :description
      t.string   :reference
      t.string   :note
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :template_id
      t.string   :parent_type
      t.integer  :parent_id
      t.string   :parent_extend

      t.timestamps
    end
  end
end
