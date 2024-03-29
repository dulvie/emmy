class WagesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :wage_period, through: :current_organization
  load_and_authorize_resource :wage, through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [[t(:wage_periods), wage_periods_path],
                    [@wage_period.name, wage_period_path(@wage_period.id)],
                    [t(:wages)]]
    @wage_periods = current_organization.wage_periods.order('id')
    if !params[:wage_period_id] && @wage_periods.count > 0
      params[:wage_period_id] = @wage_periods.first.id
    end
    @wages = current_organization.wages.where('wage_period_id=?', params[:wage_period_id])
    @wages = @wages.page(params[:page]).decorate
  end

  # GET /wages/new
  def new
    @wage.accounting_period_id = @wage_period.accounting_period_id
    @wage.wage_period_id = @wage_period.id
    @wage.wage_from = @wage_period.wage_from
    @wage.wage_to = @wage_period.wage_to
    @wage.payment_date = @wage_period.payment_date
    @wage.salary = 0
    @wage.addition = 0
    @wage.discount = 0
    @employees = current_organization.employees
  end

  # GET /wages/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        send_file(@wage.document.upload.path,
                  filename: "spec_#{@wage.id}.pdf",
                  type: 'application/pdf')
      end
    end
  end

  # GET /wage/1/edit
  def edit
    @employees = current_organization.employees
  end

  # POST /wages
  # POST /wages.json
  def create
    @wage = Wage.new(wage_params)
    @wage.organization = current_organization
    respond_to do |format|
      if @wage.save
        format.html { redirect_to wage_period_wages_path, notice: "#{t(:wage)} #{t(:was_successfully_created)}" }
      else
        @employees = current_organization.employees
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @wage.update(wage_params)
        format.html { redirect_to wage_period_wages_path, notice: "#{t(:wage)} #{t(:was_successfully_updated)}" }
      else
        @employees = current_organization.employees
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @wage.destroy
    respond_to do |format|
      format.html { redirect_to wage_period_wages_path, notice: "#{t(:wage)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def wage_params
    params.require(:wage).permit(:employee_id, :wage_from, :wage_to, :payment_date, :salary, :addition,
                                 :discount, :tax, :payroll_tax, :amount, :wage_period_id, :accounting_period_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:wage_periods), wage_periods_path],
                    [@wage_period.name, wage_period_path(@wage_period.id)],
                    [t(:wages), wage_period_wages_path],
                    [t(:wage)]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:wage_periods), wage_periods_path],
                    [@wage.wage_period.name, wage_period_path(@wage.wage_period_id)],
                    [t(:wages), wage_period_wages_path(@wage.wage_period_id)],
                    [@wage.employee.name]]
  end
end
