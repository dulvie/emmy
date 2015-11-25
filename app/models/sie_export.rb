class SieExport
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(organization, user, accounting_period, ledger)
    @organization = organization
    @accounting_period = accounting_period
    @ledger = ledger
    @user = user
  end

  attr_accessor :accounting_period, :accounting_period_id, :export_type

  def file_name
    "#{@organization.slug}_export.sie"
  end

  def directory
    'tmp/downloads'
  end

  def file_exists?
    File.exist? directory + '/' + file_name
  end

  def persisted?
    false
  end
end
