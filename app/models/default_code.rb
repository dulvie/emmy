class DefaultCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.string   :state
  # t.integer  :organization_id

  attr_accessible :code, :text

  belongs_to :organization
  has_many   :accounts

  validates :code, presence: true, uniqueness: { scope: :organization_id }
  validates :text, presence: true

  def name
    text
  end

  def can_delete?
    return false if accounts.size > 0
    true
  end
end
