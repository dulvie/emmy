class FileImporter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  LOAD = ['load']
  LOAD_CONNECT = ['load', 'load and connect']
  RELOAD = ['clear', 'reload']
  RELOAD_CONNECT = ['clear', 'reload', 'reload and connect', 'connect']

  def initialize(directory)
   @directory = directory
   @exclude_files = Array.new
  end
  
  attr_accessor :directory, :file, :type, :accounting_plan
  
  def file_filter(file_list)
    @exclude_files = file_list
  end

  def directory
    @directory
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
