class Wizard
  def self.by_name_and_controller(name, controller_name, action_name)
    case name
    when 'wages'
      WagesWizard.new(controller_name, action_name)
    else
      abort "unknown wizard"
    end
  end
end
