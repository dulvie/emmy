class TaxTableRow < ActiveRecord::Base
  # t.string   :calculation
  # t.integer  :from_wage
  # t.integer  :to_wage
  # t.integer  :column_1
  # t.integer  :column_2
  # t.integer  :column_3
  # t.integer  :column_4
  # t.integer  :column_5
  # t.integer  :column_6
  # t.integer  :organization_id
  # t.integer  :tax_table_id
  # t.timestamps


  attr_accessible :calculation, :from_wage, :to_wage, :column_1, :column_2,
    :column_3, :column_4, :column_5, :column_6, :tax_table_id

  CALCULATION_TYPES = ['belopp', 'procent']

  belongs_to :organization
  belongs_to :tax_table

  validates :calculation, inclusion: { in: CALCULATION_TYPES }
  validates :from_wage, presence: true
  validates :to_wage, presence: true
  validates :column_1, presence: true
  validates :column_2, presence: true
  validates :column_3, presence: true
  validates :column_4, presence: true
  validates :column_5, presence: true
  validates :column_6, presence: true

  def tax(column)
      case column
        when '1'
          return column_1
        when '2'
          return column_2
        when '3'
          return column_3
        when '4'
          return column_4
        when '5'
          return column_5
        when '6'
          return column_6
        else
          return 0
      end
  end

  def can_delete?
    false
  end
end
