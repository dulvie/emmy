class SimplifiedSale
  include Draper::Decoratable
  include ActiveModel::Model

  attr_accessor :our_reference_id, :customer_id, :warehouse_id, :contact_name, :invoice_text,
                :name, :price, :quantity, :vat,
                :posting_date, :description, :accounting_period_id,
                :parent_type, :parent_id, :parent_extend,
                :import_bank_file_row_id,
                :debit, :credit, :result_unit_id,
                :organization_id, :verificate_id

  validates :posting_date, presence: true
  validates :our_reference_id, presence: true
  validates :customer_id, presence: true
  validates :warehouse_id, presence: true
  validates :result_unit_id, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validate  :check_country_code

  def check_country_code
    @customer = Customer.find(customer_id)
    if (@customer.country.blank?)
      errors.add(:customer_id, :country)
      return
    end
    c = ISO3166::Country.find_country_by_alpha2(@customer.country)
    errors.add(:customer_id, :country) unless c.in_eu?
    errors.add(:customer_id, :country) if @customer.country == 'SE'
  end

  INVOICE_TEXT = ['REVERSE CHARGE']

  def submit
    return false unless valid?

    ActiveRecord::Base.transaction do
      # create sale object
      @sale = Sale.new(to_hash)
      @sale.user_id = our_reference_id
      @sale.goods_state = 'delivered'
      @sale.delivered_at = posting_date
      @sale.money_state = 'paid'
      @sale.paid_at = posting_date
      @sale.state = 'completed'
      @sale.approved_at = posting_date
      @sale.organization_id = organization_id
      return false if !@sale.save

      # create sale_item object
      @sale_item = SaleItem.new(to_hash)
      @sale_item.name = name
      sale_price = BigDecimal.new(price) * 100
      @sale_item.price = sale_price
      @sale_item.quantity = 1
      @sale_item.vat = 0
      @sale_item.row_type = 'text'
      @sale_item.sale_id = @sale.id
      @sale_item.organization_id = organization_id
      return false if !@sale_item.save
    end

    vat_number = @sale.customer.country + @sale.customer.vat_number
    sale_verificate = Services::SaleVerificate.new(@sale, posting_date)
    if sale_verificate.reverse_charge(vat_number, result_unit_id)
      Rails.logger.info "** Simplified_sale reverse_charge verificate returned ok"
    else
      Rails.logger.info "** Simplified_sale reverse_charge verificate did NOT return ok"
      return false
    end
    @import_bank_file_row = ImportBankFileRow.find(import_bank_file_row_id)
    @import_bank_file_row.set_posted
    @verificate_id = sale_verificate.verificate_id
    true
  end

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end
end
