class ProductionBatch

  include ActiveModel::Model

  attr_accessor :production_id, :item_id, :name, :comment, :in_price, :distributor_price, :retail_price, :refined_at, :expire_at,
    :quantity

  validates :name, :presence => true
  #validates :name, :uniqueness => true

  validates :item_id, :presence => true
  validates :quantity, :presence => true

  def submit
    return false unless valid?
    @production = Production.find(self.production_id)
    ActiveRecord::Base.transaction do
      @batch = Batch.new
      @batch.item_id = self.item_id
      @batch.name = self.name
      @batch.comment = self.comment
      @batch.in_price = self.in_price
      @batch.distributor_price = self.distributor_price
      @batch.retail_price = self.retail_price
      @batch.refined_at = self.refined_at
      @batch.expire_at = self.expire_at
      @batch.save

      @production.batch = @batch
      @production.quantity = self.quantity
      @production.save
    end
    return true
  end

end