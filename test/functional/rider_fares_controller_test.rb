require 'test_helper'

class RiderFaresControllerTest < ActionController::TestCase
  setup do
    @rider_fare = rider_rides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rider_fares)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rider_ride" do
    assert_difference('RiderRide.count') do
      post :create, rider_fare: {  }
    end

    assert_redirected_to rider_ride_path(assigns(:rider_fare))
  end

  test "should show rider_ride" do
    get :show, id: @rider_fare
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rider_fare
    assert_response :success
  end

  test "should update rider_ride" do
    put :update, id: @rider_fare, rider_fare: {  }
    assert_redirected_to rider_ride_path(assigns(:rider_fare))
  end

  test "should destroy rider_ride" do
    assert_difference('RiderRide.count', -1) do
      delete :destroy, id: @rider_fare
    end

    assert_redirected_to rider_rides_path
  end
end
