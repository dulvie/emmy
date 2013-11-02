require 'test_helper'

class WarehousesControllerTest < ActionController::TestCase
  setup do
    @warehouse = FactoryGirl.create(:warehouse)
  end

  #test "should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:warehouses)
  #end

end
