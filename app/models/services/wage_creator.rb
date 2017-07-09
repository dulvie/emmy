module Services
  class WageCreator
    def initialize(wage_period)
      @wage_period = wage_period
      @organization = @wage_period.organization
    end

    def save_wages
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      employee = @organization.employees
                     .where('begin < ? AND ending > ?', @wage_period.wage_to, @wage_period.wage_from)
      employee.each do |employee|
        salary = calculate_wage(employee)
        save_wage(employee, salary, @accounting_period, @wage_period)
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
            sum += ver.credit - ver.debit
          when  7600..8800
            sum += ver.credit - ver.debit
          else
        end
      end
      return sum/(1+employee.payroll_percent)
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
    end
  end
end
