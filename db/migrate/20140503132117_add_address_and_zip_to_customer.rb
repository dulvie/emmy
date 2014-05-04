class AddAddressAndZipToCustomer < ActiveRecord::Migration
  def change
  	remove_column :customers, :orgnr, :string
    add_column :customers, :address, :string
    add_column :customers, :zip, :string
    add_column :customers, :city, :string
    add_column :customers, :orgnr, :integer
  end
end
