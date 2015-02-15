class FileImporter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(directory, codes, accounting_plans)
   @directory = directory
   @exclude_files = Array.new
   @codes = codes
   @accounting_plans = accounting_plans
  end
  
  attr_accessor :directory, :file, :type, :accounting_plan
  
  def file_filter(file_list)
    @exclude_files = file_list
  end

  def directory
    @directory
  end

  def types
    types = ['load'] if @accounting_plans.size == 0 && @codes.nil?
    types = ['load', 'load and connect'] if @accounting_plans.size > 0 && @codes.nil?
    types = ['clear', 'reload'] if @accounting_plans.size == 0 && !@codes.nil?
    types = ['clear', 'reload', 'reload and connect', 'connect'] if @accounting_plans.size > 0 && !@codes.nil?
  end

  def files(file_filter)
    dir_files = Dir.glob(@directory + file_filter)
    files = Array.new
    dir_files.each do |dir_file|
      file = dir_file.gsub(@directory,'')
      unless @exclude_files.include?(file) 
        files.push(file)
      end
    end
    return files
  end

  def persisted?
    false
  end
end
