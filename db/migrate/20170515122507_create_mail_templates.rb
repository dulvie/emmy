class CreateMailTemplates  < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      t.string   :name
      t.string   :template_type
      t.string   :from
      t.string   :to
      t.string   :subject
      t.string   :attachment
      t.text     :text
      t.integer  :organization_id

      t.timestamps
    end
  end
end
