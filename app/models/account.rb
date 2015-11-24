class Account < ActiveRecord::Base
  # t.integer  :number
  # t.string   :description
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.integer  :accounting_class_id
  # t.integer  :accounting_group_id
  # t.integer  :tax_code_id
  # t.integer  :ink_code_id
  # t.integer  :ne_code_id
  # t.integer  :default_code_id
  # t.boolean  :active, null: false, default: true
  # t.timestamps

  attr_accessible :number, :description, :tax_code_id, :default_code_id, :active

  belongs_to :organization
  belongs_to :accounting_plan
  belongs_to :accounting_class
  belongs_to :accounting_group
  belongs_to :tax_code
  belongs_to :ink_code
  belongs_to :ne_code
  belongs_to :default_code
  has_many   :opening_balance_items
  has_many   :verificate_items
  has_many   :closing_balance_items

  validates :number, presence: true, uniqueness: { scope: [:organization_id, :accounting_plan] }
  validates :description, presence: true

  delegate :name, :number, to: :accounting_class, prefix: :class
  delegate :name, :number, to: :accounting_group, prefix: :class

  def toggle_active
    active == true ? self.active = false : self.active = true
  end

  def name
    number
  end

  def can_delete?
    return false if opening_balance_items.size > 0
    return false if verificate_items.size > 0
    return false if closing_balance_items.size > 0
    true
  end
end
