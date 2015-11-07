class Wizard
  def self.by_name_and_controller(name, controller_name, action_name)
    case name

    when 'economics'
      EconomicsWizard.new(controller_name, action_name)
    when 'wages'
      WagesWizard.new(controller_name, action_name)
    else
      Rails.logger.info "==>#{name}"
      abort "unknown wizard"
    end
  end
end
