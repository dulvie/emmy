class ProductionBatch
  include Draper::Decoratable
  include ActiveModel::Model

  attr_accessor :organization_id, :production_id, :item_id, :name, :comment,
                :in_price, :distributor_price, :retail_price, :refined_at,
                :expire_at, :quantity, :unit

  validates :name, presence: true
  validates :item_id, presence: true
  validates :quantity, presence: true
  validate :check_batch_name

  def check_batch_name
    u = Batch.where(organization_id: organization_id, name: name).count
    errors.add(:name, :taken) if u > 0
  end

  def submit
    return false unless valid?
    @production = Production.find(production_id)
    ActiveRecord::Base.transaction do
      @batch = Batch.new(to_hash)
      @batch.organization_id = organization_id
      @batch.save
      @production.batch = @batch
      @production.quantity = quantity
      return false if !@production.save
    end
    true
  end

  def to_hash
    hash = {}
    instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
    hash
  end
end
