class AccountsReceivablesController < ApplicationController
  respond_to :html, :json, :pdf

  def index
    @breadcrumbs = [["#{t(:accounts_receivables)}"]]
    accounting_period = current_organization.accounting_periods.last
    default_code = current_organization.default_codes.find_by_code(03)
    account = current_organization.accounts.where('accounting_plan_id = ? AND default_code_id = ?', accounting_period.accounting_plan_id, default_code.id).first
    @ledger_account = current_organization.ledger_accounts.where('account_id = ?', account.id).first
    @accounts_receivables = current_organization.sales.prepared.not_paid.order(:due_date)
                            .joins("LEFT OUTER JOIN verificates ON verificates.parent_type = 'Sale' AND verificates.parent_id = sales.id")
                            .select("sales.*, verificates.state as verificate_state, verificates.id AS verificate_id")
                            .page(params[:page]).decorate
  end

  private


end
