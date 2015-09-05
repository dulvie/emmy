module Services
  class TaxTableCreator
    require 'csv'

    def initialize(organization, user)
      @user = user
      @organization = organization
      @tax_table
    end

    def read_and_save(directory, file_name, year, table)
      name = directory + file_name
      save_tax_table('Tabell ' + table, year)
      CSV.foreach(name, { col_sep: ';' }) do |row|
        if row[1] == table
          calc = (row[0] == '30B' ? 'belopp' : 'procent')
          save_tax_table_row(calc, row[2].to_s, row[3], row[4].to_s, row[5], row[6], row[7], row[8], row[9])
        end
      end
      return true
    end
 
    def save_tax_table(name, year)
      @tax_table = TaxTable.new
      @tax_table.name = name
      @tax_table.year = year
      @tax_table.organization = @organization
      @tax_table.save
    end

    def save_tax_table_row(calculation, from_wage, to_wage, column_1, column_2, column_3, column_4, column_5, column_6)
      tax_file_row = @tax_table.tax_table_rows.build
      tax_file_row.calculation = calculation
      tax_file_row.from_wage = from_wage
      tax_file_row.to_wage = to_wage
      tax_file_row.column_1 = column_1
      tax_file_row.column_2 = column_2
      tax_file_row.column_3 = column_3
      tax_file_row.column_4 = column_4
      tax_file_row.column_5 = column_5
      tax_file_row.column_6 = column_6
      tax_file_row.organization = @organization
      tax_file_row.save
    end
  end

end
