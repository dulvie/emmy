module Services
  class WageCreator
    def initialize(organization, user, wage_period)
      @user = user
      @organization = organization
      @wage_period = wage_period
    end

    def save_wages
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      employee = @organization.employees
                     .where('begin < ? AND ending > ?', @wage_period.wage_to, @wage_period.wage_from)
      employee.each do |employee|
        save_wage(employee, employee.salary, @accounting_period, @wage_period)
      end
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
