class RemoveTaxAgencyTransactions < ActiveRecord::Migration
  def change
    drop_table :tax_agency_transactions
  end
end
