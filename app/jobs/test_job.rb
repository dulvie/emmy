class TestJob < ApplicationJob
  queue_as :default

  def perform(arg1, arg2)
    Rails.logger.info "NU KÖS UNDSJOBB: "+arg1
  end
end
