class WagesWizard < WizardBase
  def steps
    [
      [:wages_wizard, :start],
      [:tax_tables, :index],
      [:employees, :index],
      [:wage_periods, :index],
      [:wages_wizard, :stop]
    ]
  end
end
