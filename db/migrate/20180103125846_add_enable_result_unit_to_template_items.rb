class AddEnableResultUnitToTemplateItems < ActiveRecord::Migration
  def change
    add_column :template_items, :enable_result_unit, :boolean
  end
end
