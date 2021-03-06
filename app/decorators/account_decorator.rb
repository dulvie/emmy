class AccountDecorator < Draper::Decorator
  delegate_all

  def tax_code_code
    return object.tax_code.code if object.tax_code
    ''
  end

  def ink_code_code
    return object.ink_code.code if object.ink_code
    ''
  end

  def ne_code_code
    return object.ne_code.code if object.ne_code
  end
end
