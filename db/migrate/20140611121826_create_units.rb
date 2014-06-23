class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|

      t.string    :name
      t.string    :weight
      t.string    :package_dimensions

      t.timestamps

    end
  end
end