class CreateVats < ActiveRecord::Migration
  def change
    create_table :vats do |t|
      t.integer   :organization_id
      t.string    :name
      t.integer   :vat_percent

      t.timestamps

    end
    add_index :vats, [:name, :organization_id], unique: true
  end
end
