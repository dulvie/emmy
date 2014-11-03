class Material < ActiveRecord::Base
  # t.integer :organization_id
  # t.integer :production_id
  # t.integer :batch_id
  # t.integer :quantity

  belongs_to :organization
  belongs_to :production
  belongs_to :batch

  attr_accessible :batch_id, :quantity

  delegate :unit, to: :batch

  validates :batch_id, presence: true
  validates :quantity, presence: true

  def can_edit?
    production.can_edit?
  end

  def unit
  end

  def can_delete?
    return false if !production.can_edit?
    true
  end
end
