class AddEnableResultUnitToTemplateItems < ActiveRecord::Migration[7.0]
  def change
    add_column :template_items, :enable_result_unit, :boolean
  end
end
