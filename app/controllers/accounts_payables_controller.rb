class AccountsPayablesController < ApplicationController
  respond_to :html, :json, :pdf
  before_filter :load_accounting_period

  def index
    @breadcrumbs = [["#{t(:accounts_payables)}"]]
    default_code = current_organization.default_codes.find_by_code(04)
    account = current_organization.accounts.where('accounting_plan_id = ? AND default_code_id = ?', accounting_period.accounting_plan_id, default_code.id).first
    @ledger_account = current_organization.ledger_accounts.where('account_id = ?', account.id).first
    @accounts_payables = current_organization.purchases
                           .not_paid.order('due_date NULLS LAST')
                          .joins("LEFT OUTER JOIN verificates ON verificates.parent_type = 'Purchase' AND verificates.parent_id = purchases.id")
                          .select("purchases.*, verificates.state as verificate_state, verificates.id AS verificate_id")
                          .page(params[:page]).decorate
    @account_payables_paid = current_organization.purchases.where("money_state = 'paid'")
                          .joins("INNER JOIN verificates ON verificates.parent_type = 'Purchase' AND verificates.parent_id = purchases.id AND verificates.state = 'preliminary'")
                          .select("purchases.*, verificates.state as verificate_state, verificates.id AS verificate_id").decorate

  end

  private

  def load_accounting_period
    accounting_period = current_organization.accounting_periods.last
    unless accounting_period
      redirect_to helps_show_message_path()+"&message=AccountingPeriod missing", notice: "Errormessage"
    end
  end
end
