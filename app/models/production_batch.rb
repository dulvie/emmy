class ProductionBatch

  include ActiveModel::Model

  attr_accessor :organisation_id, :production_id, :item_id, :name, :comment, :in_price, :distributor_price, :retail_price, :refined_at, :expire_at,
    :quantity

  validates :name, :presence => true
  #validates :name, :uniqueness => true

  validates :item_id, :presence => true
  validates :quantity, :presence => true

  def submit
    return false unless valid?
    @production = Production.find(self.production_id)
    ActiveRecord::Base.transaction do
      @batch = Batch.new(self.to_hash)
      @batch.save
      @production.batch = @batch
      @production.quantity = self.quantity
      @production.save
    end
    return true
  end

  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end

end