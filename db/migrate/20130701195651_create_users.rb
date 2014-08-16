class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :default_locale, default: 0 # Defaults to en.
      t.timestamps
    end
  end
end
