class StockValueItem < ActiveRecord::Base
  # t.string   :name
  # t.decimal  :price, precision: 11, scale: 2, default: 0.00
  # t.integer  :quantity
  # t.integer  :value
  # t.integer  :organization_id
  # t.integer  :stock_value_id
  # t.integer  :warehouse_id
  # t.integer  :batch_id

  # t.timestamps

  before_save :calculate_value

  attr_accessible :name, :price, :quantity, :value, :warehouse_id, :batch_id

  belongs_to :stock_value
  belongs_to :warehouse
  belongs_to :batch
  belongs_to :organization

  validates :name, presence: true

  def calculate_value
    self.value = price * quantity
  end

  def can_delete?
    return false unless stock_value.can_delete?
    true
  end
end
