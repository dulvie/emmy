class AddTaxCodeIdToVerificateItems < ActiveRecord::Migration
  def change
    add_column :verificate_items, :tax_code_id, :integer
  end
end
