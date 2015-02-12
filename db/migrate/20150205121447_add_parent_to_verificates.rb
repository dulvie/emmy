class AddParentToVerificates < ActiveRecord::Migration
  def change
    add_column :verificates, :parent_type, :string
    add_column :verificates, :parent_id, :integer
    add_column :verificates, :parent_extend, :string
  end
end
