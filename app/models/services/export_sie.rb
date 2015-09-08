module Services
  class ExportSie

  def initialize(current_organization, user, directory, file_name, accounting_period, ledger)
    @current_organization = current_organization
    @accounting_period = accounting_period
    @ledger = ledger
    @user = user
    @file = directory + '/' + file_name
  end

  def create_file(export_type)
    Rails.logger.info "==>INFO"
    temp_file = @file
    File.delete(temp_file) if File.exist?(temp_file)
    case export_type
      when 'Bokslutssaldon (1)'
        balances(temp_file)
      when 'Periodsaldon (2)'
        period(temp_file)
      when 'Objektsaldon (3)'
        objects(temp_file)
      when 'Transaktioner (4)'
        transactions(temp_file)
      else
        error
    end
  end

  def balances(temp_file)
    ub = @accounting_period.closing_balance
    f = File.open(temp_file, "w")
    header.each do |row|
      f.write row + "\r\n"
    end
    accounts = ub.closing_balance_items.sort_by { |closing_balance_item| closing_balance_item.account_number}
    accounts.each do |account|
      ub = ub(account.account_number, account.account_text, account.debit - account.credit)
      f.write ub[0] + "\r\n"
      f.write ub[1] + "\r\n"
    end
    f.close
  end

  def period(temp_file)
    f = File.open(temp_file, "w")
    f.write 'Not implemented'+ "\r\n"
    f.close
  end

  def objects(temp_file)
    accounts = @ledger.ledger_accounts.sort_by { |ledger_account| ledger_account.account_number}
    f = File.open(temp_file, "w")
    header.each do |row|
      f.write row + "\r\n"
    end
    accounts.each do |account|
      result = result(account.account_number, account.account_text, account.sum)
      f.write result[0] + "\r\n"
      f.write result[1] + "\r\n"
    end
    f.close
  end

  def transactions(temp_file)
    verificates = @accounting_period.verificates
    f = File.open(temp_file, "w")
    header.each do |row|
      f.write row + "\r\n"
    end
    verificates.each do |trans|
      start = ver_start(trans.posting_date.strftime("%Y-%m-%d"), trans.description)
      f.write start[0] + "\r\n"
      f.write start[1] + "\r\n"
      trans.verificate_items.each do |item|
        item.debit = 0 if item.debit.nil?
        item.credit = 0 if item.credit.nil?
        row = trans(item.account_number, item.debit - item.credit)
        f.write row[0] + "\r\n"
      end
      f.write '}' + "\r\n"
    end
    f.close
  end

  def header
    # http://www.sie.se/wp-content/uploads/2014/01/SIE_filformat_ver_4B_080930.pdf
    ['#FLAGGA 0',
     '#PROGRAM emmy 1.0',
     '#FORMAT UTF8',
     '#GEN ' + DateTime.now.strftime("%Y-%m-%d") + ' ' + blipp(@user.name),
     '#SIETYP 4',
     '#FNAMN ' + blipp(@current_organization.name),
     '#RAR  0 ' + @accounting_period.from_formatted + ' ' + @accounting_period.to_formatted]
  end

  def ib(account, text, sum)
    ib = ['#KONTO ' + account.to_s + ' ' + blipp(text),
          '#IB ' + account.to_s + ' ' + sum.to_s]
  end

  def ub(account, text, sum)
    ub = ['#KONTO ' + account.to_s + ' ' + blipp(text),
               '#UB ' + account.to_s + ' ' + sum.to_s] 
  end

  def result(account, text, sum)
      result = ['#KONTO ' + account.to_s + ' ' + blipp(text),
                '#RES 0 ' + account.to_s + ' ' + sum.to_s]
  end

  def ver_start(date, text)
    ver_start = ['#VER ' + date + ' ' + blipp(text),
             '{']
  end

  def trans(account, sum)
    #TRANS kontonr {objektlista} belopp transdat transtext kvantitet sign
    trans = ['#TRANS ' + account.to_s + ' ' + sum.to_s]
  end
  
  def blipp(in_string)
    '"' + in_string.strip + '"'
  end
  end
end
