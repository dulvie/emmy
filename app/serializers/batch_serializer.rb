class BatchSerializer < ActiveModel::Serializer
  attributes :id, :name, :item_group, :in_price, :distributor_price, :retail_price, :vat, :unit, :expire_at, :refined_at
end
