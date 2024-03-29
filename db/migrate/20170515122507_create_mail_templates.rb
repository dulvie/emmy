class CreateMailTemplates  < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_templates do |t|
      t.string   :name
      t.string   :template_type
      t.string   :subject
      t.string   :attachment
      t.text     :text
      t.integer  :organization_id

      t.timestamps
    end
  end
end
