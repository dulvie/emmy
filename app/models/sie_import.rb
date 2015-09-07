class SieImport
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include Paperclip::Glue

  # Paperclip required callbacks
  define_model_callbacks :save, :commit, only: [:after]
  define_model_callbacks :destroy, only: [:before, :after]  

  def initialize(current_organization, accounting_period, sie_type)
    @current_organization = current_organization
    @accounting_period = accounting_period
    @sie_type = sie_type
  end

  validate :check_ib
  validate :check_ub

  def check_ib
    return true if @sie_type != 'IB'
    return true if @accounting_period.opening_balance.nil?
    errors.add(:import_type, I18n.t(:already_exists))
  end

  def check_ub
    return true if @sie_type != 'UB'
    return true if @accounting_period.closing_balance.nil?
    errors.add(:import_type, I18n.t(:already_exists))
  end

  attr_accessor :accounting_period, :accounting_period_id, :import_type

  has_attached_file :upload

  def persisted?
    false
  end
end
