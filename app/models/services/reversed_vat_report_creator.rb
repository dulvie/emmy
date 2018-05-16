module Services
  class ReversedVatReportCreator
    def initialize(reversed_vat)
      @reversed_vat = reversed_vat
      @organization = @reversed_vat.organization
    end

    def report
      # goods not implemented
      goods = 0
      # third_part not implemented
      third_part = 0

      # verificates i vat period
      @verificates = @organization.verificates
                    .where("accounting_period_id = ? AND
                            state         = 'final'  AND
                            posting_date >= ?        AND
                            posting_date <= ?",
                            @reversed_vat.accounting_period_id,
                            @reversed_vat.vat_from,
                            @reversed_vat.vat_to)

      # accounts with tax_cod should bee in the calculation
      tax_code = tax_code('39')
      accounts = Account
                     .where('accounting_plan_id = ? AND tax_code_id = ?',
                            @reversed_vat.accounting_period.accounting_plan_id, tax_code)
                     .select(:id)

      # sum all verificateItems tax_code 39 per vat_number
      ReversedVatReport.transaction do
        @verificates.each do |verificate|
          vat_number = ''
          if verificate.parent_type == 'Sale'
            @sale = @organization.sales.find(verificate.parent_id)
            @customer = @organization.customers.find(@sale.customer_id)
            vat_number = @customer.country + @customer.vat_number
          end
          services = VerificateItem
                         .where('verificate_id = ? AND account_id IN(?)', verificate.id, accounts)
                         .sum('credit-debit').to_i
          if services != 0
            save_reversed_vat_report(vat_number, goods, services, third_part)
          end
        end
      end
    end

    def delete_reversed_vat_report
      ReversedVatReport.transaction do
        reversed_vat_reports = @organization.reversed_vat_reports.where('reversed_vat_id = ? ', @reversed_vat.id)
        reversed_vat_reports.each do |reversed_vat_report|
          reversed_vat_report.destroy
        end
      end
    end

    def tax_code(code)
      @organization.tax_codes.find_by_code(code)
    end

    def save_reversed_vat_report(vat_number, goods, services, third_part)
      reversed_vat_report = @organization.reversed_vat_reports
                                .where('reversed_vat_id = ? AND vat_number = ?',
                                        @reversed_vat.id, vat_number).first
      if reversed_vat_report.nil?
        reversed_vat_report = ReversedVatReport.new
        reversed_vat_report.vat_number = vat_number
        reversed_vat_report.goods = goods
        reversed_vat_report.services = services
        reversed_vat_report.third_part = third_part
        reversed_vat_report.organization = @organization
        reversed_vat_report.accounting_period = @reversed_vat.accounting_period
        reversed_vat_report.reversed_vat = @reversed_vat
        reversed_vat_report.save
      else
        reversed_vat_report.services += services
        reversed_vat_report.save
      end
    end
  end
end
