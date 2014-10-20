class ProductionBatch
  include ActiveModel::Model

  attr_accessor :organization_id, :production_id, :item_id, :name, :comment,
                :in_price, :distributor_price, :retail_price, :refined_at,
                :expire_at, :quantity, :unit

  validates :name, presence: true

  validates :item_id, presence: true
  validates :quantity, presence: true

  def submit
    return false unless valid?
    @production = Production.find(production_id)
    ActiveRecord::Base.transaction do
      @batch = Batch.new(to_hash)
      @batch.save
      @production.batch = @batch
      @production.quantity = quantity
      @production.save
    end
    true
  end

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end
end
