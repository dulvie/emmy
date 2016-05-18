module Job
  class AccountingPlanEvent
    @queue = :accounting_plan_events
    def self.perform(accounting_plan_id, event)
      accounting_plan = AccountingPlan.find(accounting_plan_id)
      if AccountingPlan::VALID_EVENTS.include?(event)
        Rails.logger.info "will execute #{event} on #{accounting_plan.id}"
        accounting_plan.send(event)
      else
        Rails.logger.info "** Job::AccountingPlanEvent unknown event(#{event})"
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.info '** Job::AccountingPlanEvent could not find ' \
        "object with id #{accounting_plan_id}"
    end
  end
end
