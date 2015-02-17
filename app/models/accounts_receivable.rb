class AccountReceivable
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize

  end



  def persisted?
    false
  end
end
