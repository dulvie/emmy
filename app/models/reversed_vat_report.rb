class ReversedVatReport < ActiveRecord::Base
  # t.string   :vat_number
  # t.integer  :goods
  # t.integer  :services
  # t.integer  :third_part
  # t.string   :note
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :reversed_vat_id
  # t.timestamps

  attr_accessible :vat_number, :goods, :services, :third_part, :note, :accounting_period_id,
                  :reversed_vat_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :reversed_vat

  validates :accounting_period, presence: true
  validates :reversed_vat, presence: true

  def can_delete?
    true
  end
end
