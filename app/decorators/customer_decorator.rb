class CustomerDecorator < Draper::Decorator
  delegate_all

  def address_lines
    [object.name, object.address, "#{object.zip} #{object.city}", object.vat_number].collect{|i| i.to_s}
  end
end
