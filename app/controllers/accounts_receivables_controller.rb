class AccountsReceivablesController < ApplicationController
  respond_to :html, :json, :pdf
  before_filter :load_dependence

  def index
    @breadcrumbs = [["#{t(:accounts_receivables)}"]]
    account = current_organization.accounts
                  .where('accounting_plan_id = ? AND default_code_id = ?', @accounts_receivable.accounting_plan_id, @accounts_receivable.default_code_id)
                  .first
    @ledger_account = current_organization.ledger_accounts.where('account_id = ?', account.id).first
    @accounts_receivables = current_organization.sales.prepared.not_paid.order(:due_date)
                            .joins("LEFT OUTER JOIN verificates ON verificates.parent_type = 'Sale' AND verificates.parent_id = sales.id")
                            .select('sales.*, verificates.state as verificate_state, verificates.id AS verificate_id')
                            .page(params[:page]).decorate
    if @accounts_receivables.size == 0 || @ledger_account.nil?
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounts_receivables)} #{I18n.t(:missing)}")
    end
  end

  private

  def load_dependence
    @default_codes = current_organization.default_codes
    @accounting_period = current_organization.accounting_periods.last
    @accounts_receivable = AccountsReceivable.new(@accounting_period, @default_codes)
    unless @accounts_receivable.valid?
      redirect_to helps_show_message_path(message: @accounts_receivable.errors[:base][0])
    end
  end
end
