class AccountsPayable
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming


  @default_codes
  @accounting_period

  def initialize(accounting_period, default_codes)
    @accounting_period = accounting_period
    @default_codes = default_codes
  end

  validate :dependens

  def dependens
    if @accounting_period.blank?
      errors.add(:base, I18n.t(:accounting_period_missing))
      return
    end
    if @default_codes.blank?
      errors.add(:base, I18n.t(:default_codes_missing))
      return
    end
    if @default_codes.find_by_code(04).blank?
      errors.add(:base, "Default code 04 missing")
    end
  end

  def default_code_id
    default_code = @default_codes.find_by_code(04)
    return default_code.id
  end

  def accounting_plan_id
    @accounting_period.accounting_plan_id
  end

  def persisted?
    false
  end
end
