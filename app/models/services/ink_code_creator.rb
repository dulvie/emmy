module Services
  class InkCodeCreator
    require 'csv'
    def initialize(organization, ink_codes, accounting_plan)
      @organization = organization
      @ink_codes = ink_codes
      @accounting_plan = accounting_plan
    end

    def execute(type, directory, file_name)
      case type
      when 'load'
        read_and_save(type, directory, file_name)
      when 'load and connect'
        read_and_save(type, directory, file_name)
      when 'clear'
        delete_ink_codes
      when 'reload'
        delete_ink_codes
        read_and_save(type, directory, file_name)
      when 'reload and connect'
        delete_ink_codes
        read_and_save(type, directory, file_name)
      else
      end
      if file_name.start_with?('INK2')
        connect_extra_INK2 if type.include? 'connect'
      elsif file_name.start_with?('INK3')
        connect_extra_INK3 if type.include? 'connect'
      end
      true
    end

    def read_and_save(type, directory, file_name)
      name = directory + file_name
      Rails.logger.info "=>#{name}"
      first = true
      balance = true
      ink_code = 'x'
      InkCode.transaction do
      CSV.foreach(name, col_sep: ';') do |row|
        Rails.logger.info "=>#{row[1]}"
        if first
          first = false
        elsif !row[0].blank? && row[0].length == 4 && balance
          # 72nn ink_code text bas_accounts
          ink_code = row[1]
          add_ink_code(row[1], row[2], 'ub', row[3]) if type.include? 'load'
          len = row[3].length
          if row[3].include? 'exkl'
            ink_to_accounting_plan_exkl_file(ink_code, row[1], file_name) if type.include? 'connect'
          elsif len == 4
            ink_to_accounting_plan(ink_code, row[3]) if type.include? 'connect'
          else
            ink_multiple(ink_code, row[3]) if type.include? 'connect'
          end
          balance = false if row[1] == '2.50' if file_name.include? 'INK2'
          balance = false if row[1] == '5.21' if file_name.include? 'INK3'
          balance = false if row[1] == '2.35' if file_name.include? 'INK4'
        elsif !row[0].blank? && row[0].length == 4 && !row[1].blank?
          ink_code = row[1]
          add_ink_code(row[1], row[2], 'accounting_period', row[3]) if type.include? 'load'
          len = row[3].length
          if row[3].include? 'exkl'
            ink_to_accounting_plan_exkl_file(ink_code, row[1], file_name) if type.include? 'connect'
          elsif row[3].start_with?('+')
            ink_plus(ink_code, row[3]) if type.include? 'connect'
          elsif row[3].start_with?('-')
            ink_minus(ink_code, row[3]) if type.include? 'connect'
          elsif len == 4
            ink_to_accounting_plan(ink_code, row[3]) if type.include? 'connect'
          else
            ink_multiple(ink_code, row[3]) if type.include? 'connect'
          end
        end
      end
      end
    end

    def connect_extra_INK2
      InkCode.transaction do
        ink_to_accounting_plan('3.25', '884x')
      end
    end

    def connect_extra_INK3
      InkCode.transaction do
        ink_multiple('6.20', '883x, 885x, 8860, 8861-8864, 8880, 8881, 8892, 8885, 889x')
      end
    end

    def add_ink_code(code, text, sum_method, bas_accounts)
      ink_code = InkCode.new
      ink_code.code = code
      ink_code.text = text
      ink_code.sum_method = sum_method
      ink_code.bas_accounts = bas_accounts
      ink_code.organization = @organization
      ink_code.save
      ink_code.id
    end

    def delete_ink_codes
      InkCode.transaction do
        @ink_codes.each do |ink_code|
          ink_code.destroy
        end
      end
    end

    def ink_multiple(ink_code, bas_accounts)
      accounts = bas_accounts.split(', ')
      accounts.each { |account|
        ink_to_accounting_plan(ink_code, account) if account.length == 4
        ink_to_accounting_plan_interval(ink_code, account) if account.length == 9
      }
    end

    def ink_multiple_one(ink_code, bas_accounts)
      accounts = bas_accounts.split(',')
      accounts.each { |account|
        ink_to_accounting_plan(ink_code, account) if account.length == 4
        ink_to_accounting_plan_interval(ink_code, account) if account.length == 9
      }
    end

    def ink_plus(ink_code, bas_account)
      account = bas_account.gsub(/[+ ]/, '')
      ink_to_accounting_plan(ink_code, account) if account.length == 4
      ink_to_accounting_plan_interval(ink_code, account) if account.include? '-'
      ink_multiple_one(ink_code, account) if account.include? ','
    end

    def ink_minus(ink_code, bas_account)
      account = bas_account.gsub(/-/, '')
      ink_to_accounting_plan(ink_code, account) if account.length == 4
      ink_to_accounting_plan_interval(ink_code, account) if account.length == 9
    end

    def ink_to_accounting_plan(ink_code, account)
      from = set_from(account)
      to = set_tom(account)
      @ink_code = @ink_codes.find_by_code(ink_code)
      @accounting_plan.accounts
          .where('number >= ? AND number <= ?', from, to)
          .update_all(ink_code_id: @ink_code.id)
    end

    def ink_to_accounting_plan_interval(ink_code, account_interval)
      accounts = account_interval.split('-')
      from = set_from(accounts[0])
      to = set_tom(accounts[1])
      @ink_code = @ink_codes.find_by_code(ink_code)
      @accounting_plan.accounts
          .where('number >= ? AND number <= ?', from, to)
          .update_all(ink_code_id: @ink_code.id)
    end

    def ink_to_accounting_plan_exkl_file(ink_code, code, file_name)
      exkl_INK2(ink_code, code) if file_name.include? 'INK2'
      exkl_INK3(ink_code, code) if file_name.include? 'INK3'
      exkl_INK4(ink_code, code) if file_name.include? 'INK4'
    end

    def exkl_INK2(ink_code, code)
      case code
        when '2.1'
          ink_to_accounting_plan_interval(ink_code, '1000-1087')
          ink_to_accounting_plan_interval(ink_code, '1089-1099')
        when '2.3'
          ink_to_accounting_plan_interval(ink_code, '1100-1119')
          ink_to_accounting_plan_interval(ink_code, '1130-1179')
          ink_to_accounting_plan_interval(ink_code, '1190-1199')
        when '2.4'
          ink_to_accounting_plan_interval(ink_code, '1200-1279')
          ink_to_accounting_plan_interval(ink_code, '1290-1299')
        when '2.8'
          ink_to_accounting_plan_interval(ink_code, '1330-1335')
          ink_to_accounting_plan_interval(ink_code, '1338-1339')
        when '2.10'
          ink_to_accounting_plan_interval(ink_code, '1320-1345')
          ink_to_accounting_plan_interval(ink_code, '1348-1349')
        when '2.20'
          ink_to_accounting_plan_interval(ink_code, '1560-1572')
          ink_to_accounting_plan_interval(ink_code, '1574-1679')
          ink_to_accounting_plan_interval(ink_code, '1660-1679')
        when '2.25'
          ink_to_accounting_plan_interval(ink_code, '1800-1859')
          ink_to_accounting_plan_interval(ink_code, '1870-1899')
        when '2.34'
          ink_to_accounting_plan_interval(ink_code, '2220-2229')
          ink_to_accounting_plan_interval(ink_code, '2240-2299')
        when '2.38'
          ink_to_accounting_plan_interval(ink_code, '2360-2372')
          ink_to_accounting_plan_interval(ink_code, '2374-2379')
        when '2.47'
          ink_to_accounting_plan_interval(ink_code, '2460-2472')
          ink_to_accounting_plan_interval(ink_code, '2474-2479')
          ink_to_accounting_plan_interval(ink_code, '2860-2872')
          ink_to_accounting_plan_interval(ink_code, '2874-2879')
        when '2.48'
          ink_to_accounting_plan_interval(ink_code, '2490-2491')
          ink_to_accounting_plan_interval(ink_code, '2493-2499')
          ink_to_accounting_plan_interval(ink_code, '2600-2799')
          ink_to_accounting_plan_interval(ink_code, '2800-2859')
          ink_to_accounting_plan_interval(ink_code, '2473-2473')
          ink_to_accounting_plan_interval(ink_code, '2873-2473')
          ink_to_accounting_plan_interval(ink_code, '2880-2899')
        when '3.2'
          ink_to_accounting_plan_interval(ink_code, '4900-4909')
          ink_to_accounting_plan_interval(ink_code, '4932-4959')
          ink_to_accounting_plan_interval(ink_code, '4970-4979')
          ink_to_accounting_plan_interval(ink_code, '4990-4999')
        when '3.9'
          ink_to_accounting_plan_interval(ink_code, '7700-7739')
          ink_to_accounting_plan_interval(ink_code, '7750-7789')
          ink_to_accounting_plan_interval(ink_code, '7800-7899')
        when '3.12'
          ink_to_accounting_plan_interval(ink_code, '8000-8069')
          ink_to_accounting_plan_interval(ink_code, '8090-8099')
        when '3.13'
          ink_to_accounting_plan_interval(ink_code, '8100-8112')
          ink_to_accounting_plan_interval(ink_code, '8114-8117')
          ink_to_accounting_plan_interval(ink_code, '8119-8122')
          ink_to_accounting_plan_interval(ink_code, '8124-8132')
          ink_to_accounting_plan_interval(ink_code, '8134-8167')
          ink_to_accounting_plan_interval(ink_code, '8190-8199')
        when '3.15'
          ink_to_accounting_plan_interval(ink_code, '8200-8269')
          ink_to_accounting_plan_interval(ink_code, '8290-8299')
        when '3.16'
          ink_to_accounting_plan_interval(ink_code, '8300-8369')
          ink_to_accounting_plan_interval(ink_code, '8390-8399')
        when '3.25'
          ink_to_accounting_plan_interval(ink_code, '8900-8989')
        else
      end
    end

    def exkl_INK2_14(ink_code, code)
      case code
      when '2.1'
        ink_to_accounting_plan_interval(ink_code, '1000-1087')
        ink_to_accounting_plan_interval(ink_code, '1089-1099')
      when '2.3'
        ink_to_accounting_plan_interval(ink_code, '1100-1119')
        ink_to_accounting_plan_interval(ink_code, '1130-1179')
        ink_to_accounting_plan_interval(ink_code, '1190-1199')
      when '2.4'
        ink_to_accounting_plan_interval(ink_code, '1200-1279')
        ink_to_accounting_plan_interval(ink_code, '1290-1299')
      when '2.25'
        ink_to_accounting_plan_interval(ink_code, '1800-1859')
        ink_to_accounting_plan_interval(ink_code, '1870-1899')
      when '2.34'
        ink_to_accounting_plan_interval(ink_code, '2220-2229')
        ink_to_accounting_plan_interval(ink_code, '2240-2299')
      when '2.49'
        ink_to_accounting_plan_interval(ink_code, '2490-2491')
        ink_to_accounting_plan_interval(ink_code, '2493-2499')
        ink_to_accounting_plan_interval(ink_code, '2600-2799')
        ink_to_accounting_plan_interval(ink_code, '2800-2859')
        ink_to_accounting_plan_interval(ink_code, '2880-2899')
      when '3.2'
        ink_to_accounting_plan_interval(ink_code, '4900-4909')
        ink_to_accounting_plan_interval(ink_code, '4932-4959')
        ink_to_accounting_plan_interval(ink_code, '4970-4979')
        ink_to_accounting_plan_interval(ink_code, '4990-4999')
      when '3.9'
        ink_to_accounting_plan_interval(ink_code, '7700-7739')
        ink_to_accounting_plan_interval(ink_code, '7750-7789')
        ink_to_accounting_plan_interval(ink_code, '7800-7899')
      when '3.12'
        ink_to_accounting_plan_interval(ink_code, '8000-8069')
        ink_to_accounting_plan_interval(ink_code, '8090-8099')
      when '3.13'
        ink_to_accounting_plan_interval(ink_code, '8100-8169')
        ink_to_accounting_plan_interval(ink_code, '8190-8199')
      when '3.14'
        ink_to_accounting_plan_interval(ink_code, '8200-8269')
        ink_to_accounting_plan_interval(ink_code, '8290-8299')
      when '3.15'
        ink_to_accounting_plan_interval(ink_code, '8300-8369')
        ink_to_accounting_plan_interval(ink_code, '8390-8399')
      when '3.26'
        ink_to_accounting_plan_interval(ink_code, '8900-8989')
      else
      end
    end

    def exkl_INK3(ink_code, code)
      case code
      when '5.2'
        ink_to_accounting_plan_interval(ink_code, '1100-1129')
        ink_to_accounting_plan_interval(ink_code, '1131-1199')
      when '5.6'
        ink_to_accounting_plan_interval(ink_code, '1290-1290')
        ink_to_accounting_plan_interval(ink_code, '1292-1299')
      when '6.13'
        ink_to_accounting_plan_interval(ink_code, '8300-8369')
        ink_to_accounting_plan_interval(ink_code, '8390-8399')
      when '6.21'
        ink_to_accounting_plan_interval(ink_code, '8900-8989')
      else
      end
    end

    def exkl_INK4(ink_code, code)
      case code
      when '2.1'
        ink_to_accounting_plan_interval(ink_code, '1000-1087')
        ink_to_accounting_plan_interval(ink_code, '1089-1099')
      when '2.3'
        ink_to_accounting_plan_interval(ink_code, '1100-1119')
        ink_to_accounting_plan_interval(ink_code, '1130-1179')
        ink_to_accounting_plan_interval(ink_code, '1190-1199')
      when '2.4'
        ink_to_accounting_plan_interval(ink_code, '1200-1279')
        ink_to_accounting_plan_interval(ink_code, '1290-1299')
      when '2.10'
        ink_to_accounting_plan_interval(ink_code, '1400-1469')
        ink_to_accounting_plan_interval(ink_code, '1490-1499')
      when '2.14'
        ink_to_accounting_plan_interval(ink_code, '1600-1659')
        ink_to_accounting_plan_interval(ink_code, '1680-1699')
      when '2.24'
        ink_to_accounting_plan_interval(ink_code, '2100-2149')
        ink_to_accounting_plan_interval(ink_code, '2160-2199')
      when '2.27'
        ink_to_accounting_plan_interval(ink_code, '2220-2229')
      when '2.29'
        ink_to_accounting_plan_interval(ink_code, '2300-2359')
        ink_to_accounting_plan_interval(ink_code, '2380-2399')
      when '3.2'
        ink_to_accounting_plan_interval(ink_code, '4900-4909')
        ink_to_accounting_plan_interval(ink_code, '4932-4959')
        ink_to_accounting_plan_interval(ink_code, '4970-4979')
        ink_to_accounting_plan_interval(ink_code, '4990-4999')
      when '3.9'
        ink_to_accounting_plan_interval(ink_code, '7700-7739')
        ink_to_accounting_plan_interval(ink_code, '7750-7789')
        ink_to_accounting_plan_interval(ink_code, '7800-7899')
      when '3.11'
        ink_to_accounting_plan_interval(ink_code, '8000-8069')
        ink_to_accounting_plan_interval(ink_code, '8090-8099')
      when '3.12'
        ink_to_accounting_plan_interval(ink_code, '8100-8169')
        ink_to_accounting_plan_interval(ink_code, '8190-8199')
      when '3.13'
        ink_to_accounting_plan_interval(ink_code, '8200-8269')
        ink_to_accounting_plan_interval(ink_code, '8290-8299')
      when '3.14'
        ink_to_accounting_plan_interval(ink_code, '8300-8369')
        ink_to_accounting_plan_interval(ink_code, '8390-8399')
      else
      end
    end

    def set_from(account)
      nbr = account.gsub(/[x]/, '')
      if nbr.length == 3
        nbr = nbr.to_i * 10
      elsif nbr.length == 2
        nbr = nbr.to_i * 100
      end
      nbr
    end

    def set_tom(account)
      nbr = account.gsub(/[x]/, '')
      if nbr.length == 3
        nbr = nbr.to_i * 10
        nbr += 9
      elsif nbr.length == 2
        nbr = nbr.to_i * 100
        nbr += 99
      end
      nbr
    end
  end
end
