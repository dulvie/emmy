module Services
  class WageCreator
    def initialize(wage_period)
      @wage_period = wage_period
      @organization = @wage_period.organization
      @verificate_items = []
      @wage
    end

    def save_wages
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      employees = @organization.employees
                     .where('begin < ? AND ending > ?', @wage_period.wage_to, @wage_period.wage_from)
      employees.each do |employee|
        @verificate_items = []
        salary = calculate_wage(employee)
        @wage = save_wage(employee, salary, @accounting_period, @wage_period)
        pdf = generate_spec
        @wage.set_document("spec_#{@wage.id}", pdf) if !pdf.nil?
      end
      true
    end

    def calculate_wage(employee)
      return employee.salary if employee.result_unit.nil?
      fom = @wage_period.wage_from
      tom = @wage_period.wage_to
      result_unit = employee.result_unit
      @result_unit_vers = @organization.verificate_items.period(fom, tom, result_unit.id)
      sum = 0
      @result_unit_vers.each do |ver|
        case ver.account_number
          when  3000..6999
            @verificate_items.push(ver)
            sum += ver.credit - ver.debit
          when  7600..8800
            @verificate_items.push(ver)
            sum += ver.credit - ver.debit
          else
        end
      end
      return employee.salary if employee.wage_type == 'Fixed'
      return (sum/(1+employee.payroll_percent)).round
    end

    def generate_spec
      Rails.logger.info "WageCreator#generate_spec @wage: #{@wage.inspect}"
      str = WagesController.new.render_to_string(
          template: '/wages/show.pdf.haml',
          layout: 'pdf',
          locale: I18n.locale = 'se',
          locals: { :wage => @wage, :verificate_items => @verificate_items }
      )
      begin
        pdf_string = ""
        pdf_string = WickedPdf.new.pdf_from_string(str, pdf: "spec_#{@wage.id}")
      rescue Exception => e
        Rails.logger.info "==>WickedPdf Error #{e.message}"
        pdf_string = nil
      ensure
      end
      return pdf_string
    end

    def delete_wages
      @wage_period.wages.each do |wage|
        wage.delete
      end
    end

    def save_wage(employee, salary, accounting_period, wage_period)
      wage = Wage.new
      wage.employee = employee
      wage.wage_from = wage_period.wage_from
      wage.wage_to = wage_period.wage_to
      wage.payment_date = wage_period.payment_date
      wage.addition = 0
      wage.discount = 0
      wage.salary = salary
      wage.organization = @organization
      wage.accounting_period = accounting_period
      wage.wage_period = wage_period
      wage.save
      return wage
    end
  end
end
