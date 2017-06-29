class RemoveColumnsInMailTemplates  < ActiveRecord::Migration
  def change
    remove_column :mail_templates, :from
    remove_column :mail_templates, :to
  end
end
