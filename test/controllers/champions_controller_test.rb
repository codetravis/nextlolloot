require 'test_helper'

class ChampionsControllerTest < ActionController::TestCase
  test "should get collect" do
    get :collect
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

end
