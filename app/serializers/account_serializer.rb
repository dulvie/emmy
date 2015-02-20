class AccountSerializer < ActiveModel::Serializer
  attributes :id, :number, :description, :accounting_group_id
end
