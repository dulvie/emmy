class Product < ActiveRecord::Base
  # t.string :name
  # t.text :comment
  # t.string :product_type
  # t.integer :in_price
  # t.integer :distributor_price
  # t.integer :retail_price
  # t.integer :vat
  # t.string :weight
  # t.string :package_dimensions
  # t.timestamp :expire_at
  # t.timestamp :refined_at

  TYPES = ['refined', 'unrefined']

  has_and_belongs_to_many :slots

  attr_accessible :name, :product_type, :in_price, :distributor_price, :retail_price, :vat, :weight, :expire_at, :refined_at

  validates :name, :uniqueness => true
  validates :name, :presence => true

  validates :product_type, inclusion: {in: TYPES}

  before_save :fix_price_type_conversion

  # @todo Add option to upload image of the package.
  # @todo Implement state (active, inactive, archived products etc)

  # @todo Refactor into a presenter
  def product_price
    return 0 unless retail_price.to_i > 0
    retail_price + (retail_price * (vat_modifier/100))
  end

  def vat_modifier
    (vat.to_i > 0) ? vat/100 : 0
  end

  private
  def fix_price_type_conversion
    [:in_price, :distributor_price, :retail_price].each do |field|
      if self.send("#{field}_changed?")
        self.send("#{field}=", (self.send(field).to_i * 100))
      end
    end
  end

end
