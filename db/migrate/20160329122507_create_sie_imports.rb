class CreateSieImports  < ActiveRecord::Migration
  def change
    create_table :sie_imports do |t|
      t.datetime    :import_date
      t.string      :sie_type
      t.attachment  :upload
      t.string      :state
      t.integer     :accounting_period_id
      t.integer     :organization_id
      t.integer     :user_id

      t.timestamps
    end
  end
end
