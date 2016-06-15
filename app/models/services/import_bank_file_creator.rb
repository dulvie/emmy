# encoding: utf-8
module Services
  class ImportBankFileCreator
    require 'csv'

    def initialize(import_bank_file)
      @import_bank_file = import_bank_file
    end

    def read_and_save_nordea
      idx = 1
      from = '2099-12-31'
      to = '1900-01-01'
      ImportBankFileRow.transaction do
      CSV.foreach(@import_bank_file.upload.path, { col_sep: "\t",  encoding: "ISO-8859-1" }) do |row|
        case idx
        when 1
          # Check konto row[1]
        when 2
          # Rubrikrad
        else
          # bokföringsdatum, belopp, konto, namn, referens, saldo, , , , ,notering
          if row[4].length > 50
            ref = row[4].first(50)
          else
            ref = row[4]
          end
          save_bank_file_row(row[0], row[1], row[2], row[3], ref, row[10])
          from = row[0] if row[0] < from
          to = row[0] if row[0] > to
        end
        idx += idx
      end
      end
      @import_bank_file.import_date = DateTime.now
      @import_bank_file.from_date = from
      @import_bank_file.to_date = to
      @import_bank_file.save
    end

    def save_bank_file_row(posting_date, amount, bank_account, name, reference, note)
      bank_file_row = @import_bank_file.import_bank_file_rows.build
      bank_file_row.posting_date = posting_date
      bank_file_row.amount = amount.gsub(',', '.')
      bank_file_row.bank_account = bank_account
      bank_file_row.name = name
      bank_file_row.reference = reference
      bank_file_row.note = note
      bank_file_row.posted = false
      bank_file_row.organization = @import_bank_file.organization
      bank_file_row.save
    end
  end
end
