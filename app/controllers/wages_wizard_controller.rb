class WagesWizardController < ApplicationController
  include Wicked::Wizard

  steps :eko_setup, :add_tax_table, :add_employees, :create_wage_period, :close_wizard

  def new
    session[:wizard] ||= {}
    session[:wizard] = 'wage_wizard'
    @steps = steps
    redirect_to wages_wizard_path(:eko_setup)
  end

  def show
    @steps = steps
    case step
    when :eko_setup
      session[:wizard_text] = 'Är grunduppgifter för ekonomi registrerade. Om räkenskapsår saknas kan eko_wizard användas.'
      session[:wizard_confirm_url] = wages_wizard_path(:add_tax_table)
      session[:wizard_close_url] = wages_wizard_path(:close_wizard)
      @accounting_periods = current_organization.accounting_periods.order(:accounting_from)
      @accounting_periods = @accounting_periods.page(params[:page]).decorate
      render_wizard
    when :add_tax_table
      session[:wizard_text] = 'Finns alla skattetabeller som ska användas inlästa? Importera de som saknas. Bekräfta om alla finns.'
      session[:wizard_confirm_url] = wages_wizard_path(:add_employees)
      redirect_to tax_tables_path(step: @step, steps: @steps)
    when :add_employees
      session[:wizard_text] = 'Är alla anställda registrerade? Bekräfta när alla finns på plats.'
      session[:wizard_confirm_url] = wages_wizard_path(:create_wage_period)
      redirect_to employees_path
    when :create_wage_period
      session[:wizard_text] = 'Skapa löneperiod för aktuell räkenskapsår och utbetalningsperiod.'
      session[:wizard_confirm_url] = wages_wizard_path(:close_wizard)
      redirect_to wage_periods_path
    when :close_wizard
      session[:wizard] = nil
      session[:wizard_text] = nil
      session[:wizard_confirm_url] = nil
      session[:wizard_close_url] = nil
      redirect_to helps_show_help_path
    else
      session[:wizard_text] = 'Implemenattion saknas.'
      session[:wizard_confirm_url] = wages_wizard_path(:close_wizard)
      session[:wizard_close_url] = wages_wizard_path(:close_wizard)
      render_to help_show_help_path
    end

  end

  private


end
