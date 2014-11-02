class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.integer   :organization_id
      t.string    :name
      t.string    :weight
      t.string    :package_dimensions

      t.timestamps

    end
    add_index :units, [:name, :organization_id], unique: true
  end
end
