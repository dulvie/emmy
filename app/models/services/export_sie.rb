module Services
  class ExportSie
    require 'tempfile'

    def initialize(sie_export)
      @sie_export = sie_export
      @current_organization = @sie_export.organization
      @accounting_period = @sie_export.accounting_period
      @ledger = @accounting_period.ledger
      @user = @sie_export.user
    end

    def create_file(export_type)
      Rails.logger.info "==> Start creating SIE file"
      begin
        file = Tempfile.new([@sie_export.tmp_file, 'txt'])
        case export_type
          when SieExport::SIE_TYPES[0]
            balances(file)
          when SieExport::SIE_TYPES[1]
            period(file)
          when SieExport::SIE_TYPES[2]
            objects(file)
          when SieExport::SIE_TYPES[3]
            transactions(file)
          else
            error
        end
        file.flush
        @sie_export.download = file
        @sie_export.save
      ensure
        file.close
        file.unlink
      end
      Rails.logger.info "==> SIE file crated"
    end

    def balances(file)
      ub = @accounting_period.closing_balance
      header.each do |row|
        file.write row + "\r\n"
      end
      accounts = ub.closing_balance_items.sort_by { |closing_balance_item| closing_balance_item.account_number }
      accounts.each do |account|
        ub = ub(account.account_number, account.account_text, account.debit - account.credit)
        file.write ub[0] + "\r\n"
        file.write ub[1] + "\r\n"
      end
    end

    def period(file)
      file.write 'Not implemented' + "\r\n"
    end

    def objects(file)
      accounts = @ledger.ledger_accounts.sort_by { |ledger_account| ledger_account.account_number }
      header.each do |row|
        file.write row + "\r\n"
      end
      accounts.each do |account|
        result = result(account.account_number, account.account_text, account.sum)
        file.write result[0] + "\r\n"
        file.write result[1] + "\r\n"
      end
    end

    def transactions(file)
      verificates = @accounting_period.verificates.where('state = ?', 'final')
      header.each do |row|
        file.write row + "\r\n"
      end
      verificates.each do |trans|
        start = ver_start(trans.posting_date.strftime('%Y-%m-%d'), trans.description)
        file.write start[0] + "\r\n"
        file.write start[1] + "\r\n"
        trans.verificate_items.each do |item|
          item.debit = 0 if item.debit.nil?
          item.credit = 0 if item.credit.nil?
          row = trans(item.account_number, item.debit - item.credit)
          file.write row[0] + "\r\n"
        end
        file.write '}' + "\r\n"
      end
    end

    def header
      # http://www.sie.se/wp-content/uploads/2014/01/SIE_filformat_ver_4B_080930.pdf
      ['#FLAGGA 0',
       '#PROGRAM emmy 1.0',
       '#FORMAT UTF8',
       '#GEN ' + DateTime.now.strftime('%Y-%m-%d') + ' ' + blipp(@user.name),
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
      # TRANS kontonr {objektlista} belopp transdat transtext kvantitet sign
      trans = ['#TRANS ' + account.to_s + ' ' + sum.to_s]
    end

    def blipp(in_string)
      '"' + in_string.strip + '"'
    end
  end
end
