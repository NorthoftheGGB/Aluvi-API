require 'test_helper'

class OfferedRidesControllerTest < ActionController::TestCase
  setup do
    @offered_ride = offered_rides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offered_rides)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offered_ride" do
    assert_difference('OfferedRide.count') do
      post :create, offered_ride: { driver_id: @offered_ride.driver_id, rider_id: @offered_ride.rider_id }
    end

    assert_redirected_to offered_ride_path(assigns(:offered_ride))
  end

  test "should show offered_ride" do
    get :show, id: @offered_ride
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offered_ride
    assert_response :success
  end

  test "should update offered_ride" do
    put :update, id: @offered_ride, offered_ride: { driver_id: @offered_ride.driver_id, rider_id: @offered_ride.rider_id }
    assert_redirected_to offered_ride_path(assigns(:offered_ride))
  end

  test "should destroy offered_ride" do
    assert_difference('OfferedRide.count', -1) do
      delete :destroy, id: @offered_ride
    end

    assert_redirected_to offered_rides_path
  end
end
