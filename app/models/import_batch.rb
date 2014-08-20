class ImportBatch

  include ActiveModel::Model

  attr_accessor :organisation_id, :import_id, :item_id, :name,
   :description, :supplier, :contact_name, :contact_email, :batch, :quantity, :price

  validates :name, :presence => true
  #validates :name, :uniqueness => true

  validates :item_id, :presence => true
  validates :quantity, :presence => true
  validates :description, presence: true
  validates :supplier, presence: true
  validates :price, presence: true

  def submit
    return false unless valid?
    @import = Import.find(self.import_id)
    ActiveRecord::Base.transaction do

      # Create new batch for import
      @batch = Batch.new(self.to_hash)
      @batch.in_price = self.price
      @batch.save

      # Create purchase and purchase_item for import of new batch
      @purchase = @import.importing.build(organisation_id: self.organisation_id,
                                          parent_type: 'Import',
                                          parent_id: @import.id,
                                          description: self.description,
                                          supplier_id: self.supplier,
                                          contact_email: self.contact_email,
                                          contact_name: self.contact_name,
                                          our_reference_id: @import.our_reference_id,
                                          to_warehouse_id: @import.to_warehouse_id)
      @purchase.save

      @purchase_item = @purchase.purchase_items.build(organisation_id: 
                                                      self.organisation_id, 
                                                      item_id: item_id, 
                                                      batch_id: @batch.id, 
                                                      quantity: self.quantity, 
                                                      price: self.price)
      @purchase_item.save

      @import.batch = @batch
      @import.quantity = self.quantity
      @import.importing_id = @purchase.id
      @import.save
    end
    return true
  end

  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end

end