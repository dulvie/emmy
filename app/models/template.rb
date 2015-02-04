class Template < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.string   :template_type
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.timestamps

  PAY_TYPES = [' ', 'income', 'cost']

  attr_accessible :name, :description, :template_type, :accounting_plan, :accounting_plan_id

  belongs_to :organization
  belongs_to :accounting_plan
  has_many   :template_items, dependent: :destroy

  validates :name, presence: true
  validates :accounting_plan, presence: true
  validates :template_type, inclusion: { in: PAY_TYPES }

  def can_delete?
    true
  end
end
