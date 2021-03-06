module Services
  class NeCodeCreator
    require 'csv'

    def initialize(organization, ne_codes, accounting_plan)
      @organization = organization
      @ne_codes = ne_codes
      @accounting_plan = accounting_plan
    end

    def execute(type, directory, file_name)

      case type
      when 'load'
        read_and_save(type, directory, file_name)
      when 'load and connect'
        read_and_save(type, directory, file_name)
      when 'clear'
        delete_ne_codes
      when 'reload'
        delete_ne_codes
        read_and_save(type, directory, file_name)
      when 'reload and connect'
        delete_ne_codes
        read_and_save(type, directory, file_name)
      else
      end
      load_extra if type.include? 'load'
      connect if type.include? 'connect'
      true
    end

    def read_and_save(type, directory, file_name)
      name = directory + file_name
      first = true
      ne_code = ''
      NeCode.transaction do
        CSV.foreach(name, col_sep: ';') do |row|
          if first
            first = false
          elsif !row[0].blank? && row[0].length == 4
            # 72nn ne_code text account
            ink_code_id = add_ne_code(row[1], row[2], 'ub') if type.include? 'load'
            ne_code = row[1]
          elsif row[2].blank? && row[3] && row[3].length == 4
          elsif row[2].blank? && row[3] && row[3].length == 9
          end
        end
      end
    end

    def connect
      # connect from accounting_plan files for connecting to NE-codes
      directory = 'files/accounting_plans/'
      file_name = @accounting_plan.file_name
      read_and_save_connect_K1(directory, file_name) if file_name.include? 'K1_20'
      read_and_save_connect_Mini(directory, file_name) if file_name.include? 'Mini_20'
    end

    def read_and_save_connect_K1(directory, file_name)
      name = directory + file_name
      ne_code = 'x'
      first = true
      NeCode.transaction do
        CSV.foreach(name, col_sep: ';') do |row|
          if first
            first = false
          elsif row[1] && row[1].length == 4 && row[4].nil?
            ne_code = row[3]
            set_connect(row[1], row[3])
          elsif row[1] && row[1].length == 4 && row[4] && row[4].length == 4
            ne_code = row[3]
            set_connect(row[1], row[3])
            set_connect(row[4], row[6])
          elsif row[1].nil? && row[4] && row[4].length == 4
            set_connect(row[4], row[6])
          end
        end
      set_connect('2090', 'U1')
      end
    end

    def read_and_save_connect_Mini(diretory, file_name)
      name = diretory + file_name
      first = true
      NeCode.transaction do
        CSV.foreach(name, col_sep: ';') do |row|
          if first
            first = false
          elsif !row[1] && row[2]
          elsif row[1] && row[3].length == 4
            set_connect(row[3], row[1])
          elsif row[1] && row[3] == '2610-2650'
            set_connect_interval(row[3], row[1])
          elsif row[1] && row[3].length > 4
            accounts = row[3].split(', ')
            accounts.each { |account| set_connect(account, row[1]) }
          end
        end
      end
    end

    def load_extra
      NeCode.transaction do
        add_ne_code('U1', 'Upplysningar', 'ub')
        add_ne_code('U2', 'Upplysningar', 'ub')
        add_ne_code('U3', 'Upplysningar', 'ub')
        add_ne_code('U4', 'Upplysningar', 'ub')
      end
    end

    def add_ne_code(code, text, sum_method)
      ne_code = NeCode.new
      ne_code.code = code
      ne_code.text = text
      ne_code.sum_method = sum_method
      ne_code.organization = @organization
      ne_code.save
      ne_code.id
    end

    def delete_ne_codes
      NeCode.transaction do
        @ne_codes.each do |ne_code|
          ne_code.destroy
        end
      end
    end

    def set_connect(account, ne_code)
      return unless ne_code
      ne_code = ne_code[0..1] if ne_code.length > 3
      @account = @accounting_plan.accounts.find_by_number(account)
      return unless @account
      @ne_code = @organization.ne_codes.find_by_code(ne_code)
      return unless @ne_code
      @account.ne_code_id = @ne_code.id
      @account.save
    end

    def set_connect_interval(account_interval, ne_code)
      accounts = account_interval.split('-')
      from = accounts[0]
      to = accounts[1]
      @ne_code = @organization.ne_codes.find_by_code(ne_code)
      return unless @ne_code
      @accounting_plan.accounts
          .where('number >= ? AND number <= ?', from, to)
          .update_all(ne_code_id: @ne_code.id)
    end
  end
end
