module Services
  class ExportBankFileCreator
  require 'tempfile'
  include ApplicationHelper

    def initialize(organization, user, export_bank_file)
      @user = user
      @organization = organization
      @export_bank_file = export_bank_file
    end

    def read_verificates_and_create_rows
      verificates = @organization.verificates.where("state = 'preliminary' and posting_date >= ? and posting_date <= ?", @export_bank_file.from_date, @export_bank_file.to_date)
      verificates.each do |verificate|
        if verificate.bank_amount < 0
          ocr = ''
          name = verificate.parent
          bgpg = '1'
          ref = verificate.description
          cp = 'SEK'
          cd = 'SEK'
          if verificate.parent_type == 'Purchase'
            purchase = verificate.parent
            ocr = purchase.supplier_reference
            name = purchase.supplier.name
            bgpg = purchase.supplier.bg_number
          end
          save_bank_file_row(-verificate.bank_amount, bgpg, ocr, name, ref, cp, cd)
        end
      end
    end

    def test_file_PO3
      file = File.open('tmp/downloads/bank_file.txt', 'w')
      # MH00        5164005810            44580231  SEK      SEK     
      file.write(mh00('5164005810', '44580231', 'SEK', 'SEK'))
      # PI0000     8377004      2011113000000001000001234567899                         
      file.write(pi00('00', '8377004', '20111130', '100000', '1234567899'))
      # BA00                           BETALNING NR 2 OCRREF 
      file.write(ba00(' ', 'BETALNING NR 2 OCRREF'))
      # PI0005     50052976     201111300000000100000                                   
      # BA00                           BETALNING NR 5                                   
      # BM99Betalning för införda annonser under augusti månad. Avdrag för felaktigheter
      # BM99i den första annonsen har gjorts enligt överenskommelse. 
      file.write(pi00('05', '50052976', '20111130', '100000', ''))
      file.write(ba00(' ', 'BETALNING NR 5'))
      file.write(bm99('Betalning för införda annonser unde', 'r augusti månad. Avdrag för felaktigheter'))      
      file.write(bm99('i den första annonsen har gjorts en', 'ligt överenskommelse.'))
      # MT00                         0000011000000001100000 
      file.write(mt00('11', '1100000'))
      file.close
      return true
    end

    def create_file_PO3
      # OBS! export_bank_file_rows måste sorteras på cp och cd
      # Inledningspost MH00 (MH10-IBAN) per valuta
      # OBS! PI00 måste skilja på plusgiro(00) och bankgiro(05)
      counts = 0
      total = 0
      cp = ''
      cd = ''
      file = File.open('tmp/downloads/bank_file.txt', 'w')
      @export_bank_file.export_bank_file_rows.each do |row|
        if row.currency_pay != cp or row.currency_debit != cd
          cp = row.currency_pay
          cd = row.currency_debit
          file.write(mh00(@export_bank_file.organization_number, @export_bank_file.pay_account, cp, cd))
        end
        counts += 1
        total += row.amount * 100
        amount = (row.amount * 100).to_i
        file.write(pi00('00', row.bank_account, row.posting_date.strftime("%Y%m%d"), amount.to_s, row.ocr))
      end
      file.write(mt00(counts.to_s, total.to_i.to_s))
      file.close
      true
    end

    def save_bank_file_row(amount, bank_account, ocr, name, reference, cp, cd)
      bank_file_row = @export_bank_file.export_bank_file_rows.build
      bank_file_row.posting_date = @export_bank_file.export_date
      bank_file_row.amount = amount
      bank_file_row.bank_account = bank_account
      bank_file_row.ocr = ocr
      bank_file_row.name = name
      bank_file_row.reference = reference
      bank_file_row.currency_paid = cp
      bank_file_row.currency_debit = cd
      bank_file_row.organization = @organization
      bank_file_row.save
    end

    def mh00(org_nr, pay_account, cp, cd)
      post_type = 'MH00'.ljust(4)
      blank_5_12 = ' '.ljust(8)
      org_nr = org_nr.ljust(10)
      blank_23_34 = ' '.ljust(12)
      bank_account = pay_account.ljust(10)
      currency_pay = cp.ljust(3)
      blank_48_53 =' '.ljust(6)
      currency_deb = cd.ljust(3)
      blank_57_80 = ' '.ljust(24)
      record = post_type + blank_5_12 + org_nr + blank_23_34 +
               bank_account + currency_pay + blank_48_53 +
               currency_deb + blank_57_80 + "\r\n"
    end

    #00=Plusgiro, 02=Utbkort(annan def), 05=Bankgiro, 06=Pensionsinsättning(annan), 08=Löneinsättning(message=baknk)
    def pi00(type, to_account, account_date, amount, message)
      post_type = 'PI00'.ljust(4)
      pay_type = type.ljust(2)  #00=PlusGiro
      blank_7_11 = ' '.ljust(5)
      pay_to_account = to_account.ljust(11)
      blank_23_24 = ' '.ljust(2)
      pay_date = account_date.ljust(8)
      pay_amount = amount.rjust(13, '0')
      pay_message = message.ljust(25)
      blank_71_80 = ' '.ljust(10)
      record = post_type + pay_type + blank_7_11 + pay_to_account +
               blank_23_24  + pay_date + pay_amount + pay_message +
               blank_71_80 + "\r\n"
    end

    def ba00(int_note, ext_note)
      post_type = 'BA00'.ljust(4)
      intern = int_note.ljust(18)
      blank_23_31 = ' '.ljust(9)
      extern = ext_note.ljust(35)
      blank_67_80 = ' '.ljust(14)
      record = post_type + intern + blank_23_31 +
               extern + blank_67_80 + "\r\n"
    end

    def bm99(int_note, ext_note)
      post_type = 'BM99'.ljust(4)
      msg1 = int_note.ljust(35)
      msg2 = ext_note.ljust(35)
      blank_75_80 = ' '.ljust(6)
      record = post_type + msg1 +
               msg2 + blank_75_80 + "\r\n"
    end

    def mt00(counts, total)
      post_type = 'MT00'.ljust(4)
      blank_5_29 = ' '.ljust(25)
      pi00_count = counts.rjust(7, '0')
      pi00_total = total.rjust(15, '0')
      blank_52_80 = ' '.ljust(29)
      record = post_type + blank_5_29 +
               pi00_count + pi00_total + "\r\n"
    end
  end
end
