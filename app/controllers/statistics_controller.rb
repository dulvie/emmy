class StatisticsController < ApplicationController
  skip_authorization_check
  def index
    authorize! :read, Statistics::Report
  end
end
