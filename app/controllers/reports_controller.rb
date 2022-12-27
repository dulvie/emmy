class ReportsController < ApplicationController
  respond_to :html, :json, :pdf
  before_action :load_accounting_period, only: [:order_verificates_report,
                                                :order_ledger_report,
                                                :order_result_report,
                                                :order_balance_report]
  before_action :load_verificates, only: [:verificates]

  def order_verificates_report
    @breadcrumbs = [["#{t(:verificates)} #{t(:list)}"]]
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def verificates
    @verificates = @verificates.decorate
    respond_to do |format|
      format.pdf do
        render(pdf: 'verificates', template: 'reports/verificates', layout: 'pdf')
      end
      format.html
    end
  end

  def order_ledger_report
    @breadcrumbs = [["#{t(:ledger)} #{t(:report)}"]]
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def ledger
    @report = Report.new params[:report][:accounting_period]    
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)

    if params[:report][:report_type] == 'list'
      redirect_to ledger_ledger_accounts_path(@accounting_period.ledger)
      return
    end

    @ledger_accounts = current_organization.ledger_accounts
                           .where('accounting_period_id = ?', @report.accounting_period)
                           .sort_by { |ledger_account| ledger_account.account_number }

    # @verificate_items = VerificateItem
    # .joins(:verificate, :account)
    # .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final'", current_organization.id, @accounting_period.id)
    # .select('accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    # .group('accounts.number', 'accounts.description')
    # .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'ledger', template: 'reports/ledger', layout: 'pdf')
      end
      format.html
    end
  end

  def order_result_report
    @breadcrumbs = [["#{t(:result)} #{t(:report)}"]]
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
    @result_unit = current_organization.result_units
  end

  def result_report
    @report = Report.new params[:report][:accounting_period]
    result_unit_id = params[:report][:result_unit]
    if !result_unit_id.blank?
      @result_unit = current_organization.result_units.find(result_unit_id)
    end
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)
    if result_unit_id.blank?
      @verificate_items = VerificateItem
      .joins(:verificate, :account => :accounting_class)
      .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounts.number > 2999 ", current_organization.id, @accounting_period.id)
      .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
      .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
      .order('accounts.number')
    else
      @verificate_items = VerificateItem
      .joins(:verificate, :account => :accounting_class)
      .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificate_items.result_unit_id = ?  AND verificates.state = 'final' AND accounts.number > 2999 ", current_organization.id, @accounting_period.id, result_unit_id)
      .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
      .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
      .order('accounts.number')
    end  
    respond_to do |format|
      format.pdf do
        render(pdf: 'result', template: 'reports/result', layout: 'pdf')
      end
      format.html
    end
  end

  def order_balance_report
    @breadcrumbs = [["#{t(:balance)} #{t(:report)}"]]
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def balance_report
  # OBS maste plocka bort verificate som inte är final
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)

    ib = "(select sum(debit-credit)
           from opening_balance_items
           where opening_balance_items.accounting_period_id = #{@accounting_period.id} and
                 opening_balance_items.account_id = accounts.id)"

    ver = "(select sum(debit-credit)
            from verificate_items INNER JOIN verificates ON verificate_items.verificate_id = verificates.id
            where verificate_items.accounting_period_id = #{@accounting_period.id} AND
                  verificate_items.account_id = accounts.id AND
                  verificates.state = 'final')"

    @verificate_items = Account
    .joins("INNER JOIN accounting_classes ON accounting_classes.id = accounts.accounting_class_id")
    .select("accounts.number as acc,
             accounts.description as desc,
             accounting_classes.number as cls,
             accounting_classes.name as cls_desc,
             #{ib} as ib,
             #{ver} as ver")
    .where("accounts.number < '2999'")
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'balance', template: 'reports/balance', layout: 'pdf')
      end
      format.html
    end
  end

  def vat_report
    @report = Report.new(params[:from_short_date], params[:to_short_date])
    @accounting_period = AccountingPeriod.find(params[:report][:accounting_period].to_i)
    @sale_items = VerificateItem
    .joins(:verificate, :account => :accounting_group)
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_groups.number > '30' AND accounting_groups.number < '35' AND verificates.posting_date > ? AND verificates.posting_date < ? ", current_organization.id, @accounting_period.id, params[:from_short_date], params[:to_short_date])
    .select('accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounts.number', 'accounts.description')
    .order('accounts.number')

    @verificate_items = VerificateItem
    .joins(:verificate, :account => [:accounting_class, :accounting_group])
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_groups.number = '26' ", current_organization.id, @accounting_period.id)
    .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'vat_report', template: 'reports/vat_report', layout: 'pdf')
      end
      format.html
    end
  end

  def sale_statistics
    @breadcrumbs = [[t(:sale_statistics)]]
    # Statistics::SaleStat.from_params will return early if params[..].blank?
    @sale_stats = Statistics::SaleStat.list_from_params(current_organization,
                                                   params[:newer_than],
                                                   params[:older_than])
    @sale_stat_sum = Statistics::SaleStat.as_sumarized(@sale_stats)
    respond_to do |format|
      format.html
    end
  end

  private

  def load_accounting_period
    @accounting_period = current_organization.accounting_periods.where('active = true').first
    unless @accounting_period
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end

  def load_verificates
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)
    @verificates = current_organization.verificates
                       .where("accounting_period_id = ? AND state = 'final'", @accounting_period.id)
                       .order(:number)
    if @verificates.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:verificates)} #{I18n.t(:missing)}")
    end
  end
end
