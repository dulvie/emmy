module Services
  class TaxCodeCreator
    require 'csv'

    def initialize(organization, user, tax_codes, accounting_plan)
      @user = user
      @organization = organization
      @tax_codes = tax_codes
      @accounting_plan = accounting_plan
    end

    def execute(type, directory, file_name)
      case type
        when 'load'
          read_and_save(type, directory, file_name)
        when 'load and connect'
          read_and_save(type, directory, file_name)
        when 'clear'
          delete_tax_codes
        when 'reload'
          delete_tax_codes
          read_and_save(type, directory, file_name)
        when 'reload and connect'
          delete_tax_codes
          read_and_save(type, directory, file_name)
        when 'connect'
          read_and_save(type, directory, file_name)
        else
      end
      
      return true 
    end

    def read_and_save(type, directory, file_name)
      accounting_plan_file = @accounting_plan
      name = directory + file_name
      first = true
      CSV.foreach(name, { :col_sep => ';' }) do |row|
        if row[0] && row[0] == 'code'
          # row-type code text method type
          add_tax_code(row[1], row[2], row[3], row[4]) if type.include? "load"
        elsif row[0] && row[0] == 'connect'
          connect(row[1], row[2], row[3]) if type.include? "connect"
        end
      end
    end

    def connect(plan, account, code)
      set_connect(account, code) if @accounting_plan.file_name.include? plan
    end

    def add_tax_code(code, text, sum_method, code_type)
      tax_code = TaxCode.new
      tax_code.code = code
      tax_code.text = text
      tax_code.sum_method = sum_method
      tax_code.code_type = code_type
      tax_code.organization = @organization
      tax_code.save
    end

    def delete_tax_codes
      @tax_codes.each do |tax_code|
        tax_code.destroy
      end
    end

    def set_connect(account, tax_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      return if !@account
      @tax_code = @organization.tax_codes.find_by_code(tax_code)
      return if !@tax_code
      @account.tax_code_id = @tax_code.id
      @account.save
    end
  end
end
