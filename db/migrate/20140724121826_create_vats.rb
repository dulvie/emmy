class CreateVats < ActiveRecord::Migration
  def change
    create_table :vats do |t|

      t.string    :name
      t.integer   :vat_percent

      t.timestamps

    end
  end
end
