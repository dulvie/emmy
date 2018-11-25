class ImportBatch
  include ActiveModel::Model

  attr_accessor :organization_id, :import_id, :item_id, :name,
                :description, :supplier, :contact_name, :contact_email, :batch,
                :quantity, :price, :unit

  validates :name, presence: true
  validates :item_id, presence: true
  validates :quantity, presence: true
  validates :description, presence: true
  validates :supplier, presence: true
  validates :price, presence: true
  validate :check_batch_name

  def check_batch_name
    u = Batch.where('organization_id = ? and name = ?', organization_id, name).count
    errors.add(:name, t(:'errors.messages.taken')) if u > 0
  end

  def submit
    return false unless valid?
    @import = Import.find(import_id)
    ActiveRecord::Base.transaction do

      # Create new batch for import
      @batch = Batch.new(item_id: item_id,
                         name: name,
                         in_price: price)
      return false unless @batch.save

      # Create purchase and purchase_item for import of new batch
      @purchase = @import.importing.build(parent_type: 'Import',
                                          parent_id: @import.id,
                                          description: description,
                                          supplier_id: supplier,
                                          contact_email: contact_email,
                                          contact_name: contact_name,
                                          our_reference_id: @import.our_reference_id,
                                          to_warehouse_id: @import.to_warehouse_id)
      @purchase.organization_id = organization_id
      return false unless @purchase.save

      @purchase_item = @purchase.purchase_items.build(item_id: item_id,
                                                      batch_id: @batch.id,
                                                      quantity: quantity,
                                                      price: price)
      @purchase_item.organization_id = organization_id
      return false unless @purchase_item.save

      @import.batch = @batch
      @import.quantity = quantity
      @import.importing_id = @purchase.id
      return false unless @import.save
    end
    true
  end

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end
end
