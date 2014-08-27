class Material < ActiveRecord::Base
  # t.integer :organisation_id
  # t.integer :production_id
  # t.integer :batch_id
  # t.integer :quantity

  belongs_to :organisation
  belongs_to :production
  belongs_to :batch

  attr_accessible :batch_id, :quantity, :organisation

  validates :batch_id, presence: true
  validates :quantity, presence: true


  def can_edit?
    production.can_edit?
  end

end
