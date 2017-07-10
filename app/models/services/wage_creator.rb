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
      employee = @organization.employees
                     .where('begin < ? AND ending > ?', @wage_period.wage_to, @wage_period.wage_from)
      employee.each do |employee|
        @verificate_items = []
        salary = calculate_wage(employee)
        @wage = save_wage(employee, salary, @accounting_period, @wage_period)
        generate_spec if !@verificate_items.nil?
      end
    end

    def calculate_wage(employee)
      return employee.salary if employee.wage_type == 'Fixed'
      period = @wage_period.accounting_period_id
      result_unit = employee.result_unit
      @result_unit_vers = @organization.verificate_items.period(period, result_unit.id)
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
      return (sum/(1+employee.payroll_percent)).round
    end

    def generate_spec
      Rails.logger.info "==>#{@wage.inspect}"
      pdf_string = WickedPdf.new.pdf_from_string(
          WagesController.new.render_to_string(
              template: '/wages/show.pdf.haml',
              layout: 'pdf',
              locale: I18n.locale = 'se',
              locals: { :wage => @wage, :verificate_items => @verificate_items }
          ),
          pdf: "spec_#{@wage.id}"
      )
      @wage.set_document("spec_#{@wage.id}", pdf_string)
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
