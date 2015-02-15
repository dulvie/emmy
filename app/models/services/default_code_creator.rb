module Services
  class DefaultCodeCreator
    require 'csv'

    def initialize(organization, user, default_codes, accounting_plan)
      @user = user
      @organization = organization
      @default_codes = default_codes
      @accounting_plan = accounting_plan
    end

    def execute(type, directory, file_name)
      case type
        when 'load'
          read_and_save(type, directory, file_name)
        when 'load and connect'
          read_and_save(type, directory, file_name)
        when 'clear'
          delete_default_codes
        when 'reload'
          delete_default_codes
          read_and_save(type, directory, file_name)
        when 'reload and connect'
          delete_default_codes
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
          add_default_code(row[1], row[2]) if type.include? "load"
        elsif row[0] && row[0] == 'connect'
          connect(row[1], row[2], row[3]) if type.include? "connect"
        end
      end
    end

    def connect(plan, account, code)
      set_connect(account, code) if @accounting_plan.file_name.include? plan
    end

    def add_default_code(code, text)
      default_code = DefaultCode.new
      default_code.code = code
      default_code.text = text
      default_code.organization = @organization
      default_code.save
    end

    def delete_default_codes
      @default_codes.each do |default_code|
        default_code.destroy
      end
    end

    def set_connect(account, default_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      return if !@account
      @default_code = @organization.default_codes.find_by_code(default_code)
      return if !@default_code
      @account.default_code_id = @default_code.id
      @account.save
    end
  end
end
