class Material < ActiveRecord::Base

  #t.integer :production_id
  #t.integer :product_id
  #t.integer :quantity

  belongs_to :production
  belongs_to :product

  attr_accessible :product_id, :quantity

  validates :product_id, presence: true
  validates :quantity, presence: true

  def can_edit?
    production.can_edit?
  end
  
  private

end
