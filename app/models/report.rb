class Report
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(accounting_period)
    @accounting_period = accounting_period
  end

  attr_accessor :accounting_period, :result_unit

  TYPES = ['pdf', 'list']

  def report_type
  end

  def persisted?
    false
  end
end
