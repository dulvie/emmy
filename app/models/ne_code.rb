class NeCode < ActiveRecord::Base
  # t.string   :code
  # t.string   :text
  # t.string   :sum_method
  # t.integer  :organization_id

  #attr_accessible :code, :text, :sum_method

  belongs_to :organization
  has_many   :accounts

  SUM_METHODS = ['ub', 'accounting_period', 'total', 'none']

  validates :code, presence: true, uniqueness: { scope: :organization_id }
  validates :text, presence: true
  validates :sum_method, inclusion: { in: SUM_METHODS }

  def name
    text
  end

  def can_delete?
    return false if accounts.size > 0
    return false if sum_method == 'total'
    true
  end
end
