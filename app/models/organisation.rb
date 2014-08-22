class Organisation < ActiveRecord::Base
  # t.string :name
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :vat_number
  # t.string :bankgiro
  # t.string :postgiro
  # t.string :plusgiro
  # t.timestamps

  attr_accessible :email, :name, :address, :zip, :vat_number, :bankgiro, :postgiro, :plusgiro, :city

  def can_delete?
    false
  end
end
