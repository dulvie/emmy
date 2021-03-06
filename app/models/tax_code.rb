class TaxCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.string   :sum_method
  # t.string   :code_type
  # t.integer  :organization_id

  attr_accessible :code, :text, :sum_method, :code_type

  belongs_to :organization
  has_many   :accounts

  SUM_METHODS = ['accounting_period', 'vat_period', 'total', 'wage_period', 'subset_55',
                 'subset_56', 'subset_57', 'subset_58', 'subset_59', 'subset_60',
                 'subset_61', 'subset_62', 'include_81', 'verificate_items', 'none']
  CODE_TYPES = ['vat', 'wage', 'default']
  VAT_PURCHASE = [30,31,32]
  VAT_PURCHASE_BASIS = [20,21,22,23,24]

  validates :code, presence: true, uniqueness: { scope: :organization_id }
  validates :text, presence: true
  validates :sum_method, inclusion: { in: SUM_METHODS }
  validates :code_type, inclusion: { in: CODE_TYPES }

  scope :vat, -> { where(code_type: 'vat') }
  scope :wage, -> { where(code_type: 'wage') }
  scope :default, -> { where(code_type: 'default') }

  scope :vat_purchase, -> { where("code in (?)", VAT_PURCHASE)}
  scope :vat_purchase_basis, -> { where("code in(?)", VAT_PURCHASE_BASIS)}

  def vat_purchase
    VAT_PURCHASE.include? code
  end

  def vat_purchase_basis
    VAT_PURCHASE_BASIS.include? code
  end

  def name
    text
  end

  def can_delete?
    return false if accounts.size > 0
    return false if sum_method == 'total'
    return false if code_type == 'default'
    true
  end
end
