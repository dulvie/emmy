class ProductDecorator < Draper::Decorator
  delegate :all

  [:in_price, :distributor_price, :retail_price].each do |field|
    define_method(field) do
      sprintf('%.2f', object.send(field) / 100.0)
    end
  end
end
