# encoding: utf-8
class WagesWizardController < ApplicationController
  before_action :set_wizard

  def set_wizard
    @wizard = Wizard.by_name_and_controller('wages', 'wages_wizard', action_name)
  end

  def new
    session[:wizard] ||= {}
    session[:wizard] = 'wages'
    redirect_to wages_wizard_path(:eko_setup)
  end

  def start
    @accounting_periods = current_organization.accounting_periods.order(:accounting_from)
    @accounting_periods = @accounting_periods.page(params[:page]).decorate
    session[:wizard] = 'wages'
  end

  def stop
    session[:wizard] = nil
  end
end
