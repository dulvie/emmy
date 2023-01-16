class AddTaxCodeIdToVerificateItems < ActiveRecord::Migration[7.0]
  def change
    add_column :verificate_items, :tax_code_id, :integer
  end
end
