class ResultUnit < ActiveRecord::Base
  # t.integer  :name
  # t.integer  :organization_id
  # t.integer  :employee_id

  attr_accessible :name, :employee_id

  belongs_to :organization
  belongs_to :employee
  has_many   :verificate_items

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :employee_id, uniqueness: { scope: :organization_id }, if: :check_employee

  def check_employee
    return false if self.employee_id.nil?
    return true
  end

  def can_delete?
    return false if verificate_items.size > 0
    true
  end
end
