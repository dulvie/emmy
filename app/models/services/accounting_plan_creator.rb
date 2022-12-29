module Services
  class AccountingPlanCreator
    require 'csv'

    def initialize(accounting_plan)
      @accounting_plan = accounting_plan
      @organization = @accounting_plan.organization
      @accounting_group
    end

    def read_and_save(directory, file_name)
      Rails.logger.info "->#{file_name}"
      case file_name
      when 'Kontoplan_K1_Mini_2014_ver1.csv'
        K1_Mini_read_and_save(directory, file_name)
      when 'Kontoplan_K1_2014_ver1.csv'
        K1_read_and_save(directory, file_name)
      when 'Kontoplan_Normal_2014_ver1.csv'
        BAS_read_and_save(directory, file_name)
      when 'Kontoplan_Normal_2018.csv'
          BAS_read_and_save(directory, file_name)
      else
      end
      return true
    end

    def K1_Mini_read_and_save(diretory, file_name)
      name = diretory + file_name
      class_id = 'x'
      class_name = ['B1-B5', 'B6-B9', 'B10', 'B13-B16', 'R1-R4', 'R5-R8', 'R9-R10', 'U1-U4']
      nbr = 0
      first = true
      CSV.foreach(name, col_sep: ';') do |row|
        if first
          save_account_plan(row[1],'importerat', file_name)
          first = false
        elsif !row[1] && row[2]
          class_id = save_account_class(class_name[nbr], row[2])
          nbr += 1
        elsif row[1] && row[3].length == 4
          save_account(row[3], row[2], class_id, nil)
        elsif row[1] && row[3] == '2610-2650'
          save_account('2610', row[2], class_id, nil)
          save_account('2620', row[2], class_id, nil)
          save_account('2630', row[2], class_id, nil)
          save_account('2640', row[2], class_id, nil)
          save_account('2650', row[2], class_id, nil)
        elsif row[1] && row[3].length > 4
          accounts = row[3].split(', ')
          accounts.each { |account|
            save_account(account, row[2], class_id, nil) if !check_account(account)
          }
        else
        end
      end
    end

    def K1_read_and_save(directory, file_name)
      name = directory + file_name
      class_id = 'x'
      group_id = 'x'
      first = true
      CSV.foreach(name, col_sep: ';') do |row|
        if first
          save_account_plan(row[1],'importerat', file_name)
          first = false
        elsif row[1] && (row[1].at(1) == ' ' || row[1].at(3) == ' ')
          i = row[1].index(' ')
          class_id = save_account_class(row[1][0,i], row[1][i..99])
        elsif row[1] && (row[1].at(2) == ' ' || row[1].at(5) == ' ')
          i = row[1].index(' ')
          group_id = save_account_group(row[1][0,i], row[1][i..99])
        elsif row[1] && row[1].length == 4 && row[4].nil?
          save_account(row[1], row[2], class_id, group_id)
        elsif row[1] && row[1].length == 4 && row[4] && row[4].length == 4
          save_account(row[1], row[2], class_id, group_id)
          save_account(row[4], row[5], class_id, group_id)
        elsif row[1].nil? && row[4] && row[4].length == 4
          save_account(row[4], row[5], class_id, group_id)
        end
      end
    end

    def BAS_read_and_save(directory, file_name)
      name = directory + file_name
      class_id = 'x'
      group_id = 'x'
      first = true
      CSV.foreach(name, col_sep: ';') do |row|
        if first
          save_account_plan(row[1],'importerat', file_name)
          first = false
        elsif row[2].blank? && row[5] && row[5].length == 4
          save_account(row[5], row[6], class_id, group_id) if !check_account(row[5])
        elsif ((row[2] && row[2].strip.length == 1) || (row[2] && row[2].length == 3))
          class_id = save_account_class(row[2], row[3])
        elsif ((row[2] && row[2].length == 2) || (row[2] && row[2].length == 5))
          group_id = save_account_group(row[2], row[3])
        elsif row[2] && row[2].length == 4 && row[5].blank?
          save_account(row[2], row[3], class_id, group_id)
        elsif row[2] && row[2].length == 4 && row[5] && row[5].length == 4
          save_account(row[2], row[3], class_id, group_id)
          save_account(row[5], row[6], class_id, group_id) if !check_account(row[5])
        end
      end
    end

    def BAS_set_active(directory, file_name)
      name = directory + file_name
      first = true
      Account.transaction do
      CSV.foreach(name, col_sep: ';') do |row|
        if first
          first = false
        elsif row[2].blank? && row[5] && row[5].length == 4
          save_active(row[4], row[5])
        elsif ((row[2] && row[2].strip.length == 1) || (row[2] && row[2].length == 3))
          class_id = 'x'
        elsif ((row[2] && row[2].length == 2) || (row[2] && row[2].length == 5))
          group_id = 'y'
        elsif row[2] && row[2].length == 4 && row[5].blank?
          save_active(row[1], row[2])
        elsif row[2] && row[2].length == 4 && row[5] && row[5].length == 4
          save_active(row[1], row[2])
          save_active(row[4], row[5])
        end
      end
      end
      return true
    end

    def K1_tax_code_update
      update_account_tax_code('3000', 05)
      update_account_tax_code('2610', 10)
      update_account_tax_code('2620', 11)
      update_account_tax_code('2630', 12)
      update_account_tax_code('2640', 48)

      update_account_tax_code('7000', 50)
      update_account_tax_code('2730', 78)
      update_account_tax_code('2710', 82)

      update_account_tax_code('1920', 101)
      update_account_tax_code('7500', 102)
    end

    def save_account_plan(name, description, file_name)
      @accounting_plan.name = name
      @accounting_plan.description = description
      @accounting_plan.file_name = file_name
      @accounting_plan.save
    end

    def save_account_class(number, name)
      @accounting_class = @accounting_plan.accounting_classes.build
      @accounting_class.number = number
      @accounting_class.name = name
      @accounting_class.organization_id = @organization.id
      @accounting_class.accounting_plan_id = @accounting_plan.id
      @accounting_class.save
      return @accounting_class.id
    end

    def save_account_group(number, name)
      @accounting_group = @accounting_plan.accounting_groups.build
      @accounting_group.number = number
      @accounting_group.name = name
      @accounting_group.organization_id = @organization.id
      @accounting_group.accounting_plan_id = @accounting_plan.id
      @accounting_group.save
      return @accounting_group.id
    end

    def save_account(number, name, class_id, group_id)
      @account = @accounting_plan.accounts.build
      @account.number = number
      @account.description = name
      @account.organization_id = @organization.id
      @account.accounting_plan_id = @accounting_plan.id
      @account.accounting_class_id = class_id
      @account.accounting_group_id = group_id if group_id
      @account.save
    end

    def update_account_tax_code(account, tax_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      @tax_code = @organization.tax_codes.find_by_code(tax_code)
      @account.tax_code = @tax_code
      @account.save
    end

    def update_account_ink_code(account, ink_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      @ink_code = @organization.ink_codes.find_by_code(ink_code)
      @account.ink_code = @ink_code
      @account.save
    end

    def save_active(fld, account)
      Rails.logger.info "-->#{fld} #{account}"
      active = 'false'
      active = 'true' if fld == ' ■'
      @account = @accounting_plan.accounts.find_by_number(account)
      @account.active = active
      @account.save
    end

    # Same account multiple times is not working with state change
    def check_account(account)
      return true if @accounting_plan.accounts.find_by_number(account)
      return false
    end
  end
end
