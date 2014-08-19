class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.integer   :organisation_id
      t.string    :name
      t.string    :weight
      t.string    :package_dimensions

      t.timestamps

    end
  end
end
