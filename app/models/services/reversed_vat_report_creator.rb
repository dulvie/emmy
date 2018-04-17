module Services
  class ReversedVatReportCreator
    def initialize(reversed_vat)
      @reversed_vat = reversed_vat
      @organization = @reversed_vat.organization
    end

    def report
      Rails.logger.info "3"
      # goods not implemented
      goods = 0
      # third_part not implemented
      third_part = 0
      # todo where to find all vat_numbers
      vat_numbers = ['', 'FI121212', 'GB212121']
      # todo alla account with tax_cod should bee in the calculation
      tax_code = tax_code('39')

      verificate = @organization.verificates
                    .where("accounting_period_id = ? AND state = 'final' AND posting_date >= ?
                                                                         AND posting_date <= ?",
                                          @reversed_vat.accounting_period_id,
                                          @reversed_vat.vat_from,
                                          @reversed_vat.vat_to)
                                  .select(:id)

      accounts = Account
                     .where('accounting_plan_id = ? AND tax_code_id = ?',
                            @reversed_vat.accounting_period.accounting_plan_id, tax_code)
                     .select(:id)
      Rails.logger.info "4"
      # sum all verificateItems tax_code 39 per vat_number
      ReversedVatReport.transaction do
        vat_numbers.each do |vat_number|
          services = VerificateItem
                         .where('verificate_id IN(?) AND account_id IN(?)', verificate, accounts)
                         .sum('debit-credit')
          save_reversed_vat_report(vat_number, goods, services, third_part)
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
      Rails.logger.info "6"
      reversed_vat_report = ReversedVatReport.new
      reversed_vat_report.vat_number = vat_number
      reversed_vat_report.goods = goods
      reversed_vat_report.services = services
      reversed_vat_report.third_part = third_part
      reversed_vat_report.organization = @organization
      reversed_vat_report.accounting_period = @reversed_vat.accounting_period
      reversed_vat_report.reversed_vat = @reversed_vat
      reversed_vat_report.save
    end
  end
end
