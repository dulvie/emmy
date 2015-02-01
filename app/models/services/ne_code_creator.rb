module Services
  class NeCodeCreator
    require 'csv'
    def initialize(organization, user)
      @user = user
      @organization = organization
    end

    def read_and_save
      first = true
      CSV.foreach('NE_K1_15_ver1-1.csv', { :col_sep => ';' }) do |row|
        if first
          first = false
        elsif !row[0].blank? && row[0].length == 4
          ink_code_id = add_ne_code(row[1], row[2], 'ub')
        end
      end
    end

    def add_ne_code(code, text, sum_method)
      ne_code = NeCode.new
      ne_code.code = code
      ne_code.text = text
      ne_code.sum_method = sum_method
      ne_code.organization = @organization
      ne_code.save
      return ne_code.id
    end
  end
end
