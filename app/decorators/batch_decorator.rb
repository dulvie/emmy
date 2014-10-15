class BatchDecorator < Draper::Decorator
  delegate_all

  [:in_price, :distributor_price, :retail_price].each do |field|
    define_method(field) do
      return 0 if object.send(field).nil?
      sprintf('%.2f', object.send(field) / 100.0)
    end
  end

  def batch_price
    return 0 unless retail_price.to_i > 0
    retail_price + (retail_price * vat.add_factor)
  end

  # This might be stupid, maybe always use % instead?
  # if vat is larger than 0, de
  def vat_modifier
    vat.to_i > 0 ? vat/100.0 : vat || 0
  end
end
