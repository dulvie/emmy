class WizardBase

  attr_accessor :controller_name, :action_name

  def initialize(controller_name, action_name)
    @controller_name = controller_name
    @action_name = action_name
  end

  def steps
    fail "You need to implement #steps"
  end

  def name
    self.class.name.downcase
  end

  def log(msg)
    Rails.logger.info "WIZARD: #{msg}"
  end

  def step_name
    "#{controller_name} : #{action_name}"
  end

  def current_step
    log "current step, steps; #{steps.inspect}"
    steps.each_with_index do |step, i|
      log "on step(#{step}) i: #{i} ;;;;;; step_name: (#{step_name})"
      return i if step[0] == controller_name.to_sym && step[1] == action_name.to_sym
    end
    fail "unkown step: #{step_name} valid steps: #{steps.inspect}"
  end

  def next_step
    return nil if current_step >= (steps.size - 1)
    steps[current_step + 1]
  end

  def previous_step
    return nil if current_step <= 0
    steps[current_step - 1]
  end

  def text_symbol(step)
    "wizard_#{name.to_s.gsub('wizard', '')}_#{step.join('_')}_text"
  end

  def title_symbol(step)
    "wizard_#{name.to_s.gsub('wizard', '')}_#{step.join('_')}_title"
  end

end
