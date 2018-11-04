class AccountsPayablesController < ApplicationController
  respond_to :html, :json, :pdf
  before_action :load_dependence

  def index
    @breadcrumbs = [["#{t(:accounts_payables)}"]]
    account = current_organization.accounts
                  .where('accounting_plan_id = ? AND default_code_id = ?', @accounts_payable.accounting_plan_id, @accounts_payable.default_code_id)
                  .first
    @ledger_account = current_organization.ledger_accounts.where('account_id = ?', account.id).first
    @accounts_payables = current_organization.purchases
                           .not_paid.order('due_date NULLS LAST')
                          .joins("LEFT OUTER JOIN verificates ON verificates.parent_type = 'Purchase' AND verificates.parent_id = purchases.id")
                          .select('purchases.*, verificates.state as verificate_state, verificates.id AS verificate_id')
                          .page(params[:page]).decorate
    @account_payables_paid = current_organization.purchases.where("money_state = 'paid'")
                          .joins("INNER JOIN verificates ON verificates.parent_type = 'Purchase' AND verificates.parent_id = purchases.id AND verificates.state = 'preliminary'")
                          .select('purchases.*, verificates.state as verificate_state, verificates.id AS verificate_id').decorate
    if @accounts_payables.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounts_payables)} #{I18n.t(:missing)}")
    end
    if !@ledger_account
      redirect_to helps_show_message_path(message: "#{I18n.t(:ledger_accounts)} #{I18n.t(:missing)}")
    end
  end

  private

  def load_dependence
    @default_codes = current_organization.default_codes
    @accounting_period = current_organization.accounting_periods.last
    @accounts_payable = AccountsPayable.new(@accounting_period, @default_codes)
    unless @accounts_payable.valid?
      redirect_to helps_show_message_path(message: @accounts_payable.errors[:base][0])
    end
  end
end
