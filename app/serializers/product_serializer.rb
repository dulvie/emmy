class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :unit, :weight, :expire_at, :refined_at
end
