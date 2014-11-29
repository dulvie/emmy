class AddCanceledAtToSale < ActiveRecord::Migration
  def change
     add_column :sales, :canceled_at, :timestamp
  end
end
