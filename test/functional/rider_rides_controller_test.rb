require 'test_helper'

class RiderRidesControllerTest < ActionController::TestCase
  setup do
    @rider_ride = rider_rides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rider_rides)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rider_ride" do
    assert_difference('RiderRide.count') do
      post :create, rider_ride: { references: @rider_ride.references, references: @rider_ride.references }
    end

    assert_redirected_to rider_ride_path(assigns(:rider_ride))
  end

  test "should show rider_ride" do
    get :show, id: @rider_ride
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rider_ride
    assert_response :success
  end

  test "should update rider_ride" do
    put :update, id: @rider_ride, rider_ride: { references: @rider_ride.references, references: @rider_ride.references }
    assert_redirected_to rider_ride_path(assigns(:rider_ride))
  end

  test "should destroy rider_ride" do
    assert_difference('RiderRide.count', -1) do
      delete :destroy, id: @rider_ride
    end

    assert_redirected_to rider_rides_path
  end
end
