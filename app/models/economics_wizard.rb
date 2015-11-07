class EconomicsWizard < WizardBase
  def steps
    [
      [:accounting_plans, :index],
      [:tax_codes, :index],
      [:ink_codes, :index],
      [:ne_codes, :index],
      [:default_codes, :index],
      [:templates, :index],
      [:accounting_periods, :index],
      [:economics_wizard, :stop]
    ]
  end
end
