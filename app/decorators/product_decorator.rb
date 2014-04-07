class ProductDecorator < Draper::Decorator
  delegate_all

  [:in_price, :distributor_price, :retail_price].each do |field|
    define_method(field) do
      sprintf('%.2f', object.send(field) / 100.0)
    end
  end

  def product_price
    return 0 unless retail_price.to_i > 0
    retail_price + (retail_price * vat_modifier)
  end

  # This might be stupid, maybe always use % instead?
  # if vat is larger than 0, de
  def vat_modifier
    vat.to_i > 0 ? vat/100.0 : vat
  end

end
