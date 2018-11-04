# encoding: utf-8
class EconomicsWizardController < ApplicationController
  before_action :set_wizard

  def set_wizard
    @wizard = Wizard.by_name_and_controller('economics', 'economics_wizard', action_name)
    session[:wizard] = 'economics' unless session[:wizard] == 'economics'
  end

  def start
    redirect_to accounting_plans_path
  end

  def stop
    session[:wizard] = nil
  end
end
