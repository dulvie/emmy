class AccountingGroupSerializer < ActiveModel::Serializer
  attributes :id, :number, :name
  #attributes :group_id, :group_name, :accounts_id, :accounts_number, :accounts_desc
  #has_many :accounts
  #def accounts
  #  object.accounts.order("number")
  #end
  #def accounts
  #  object.accounts.select(:number, :description)
  #end

end
