require 'test_helper'

class RidesControllerTest < ActionController::TestCase
  setup do
    @ride = ride_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rides)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ride_request" do
    assert_difference('RideRequest.count') do
      post :create, ride: { destination: @ride.destination, destination_place_name: @ride.destination_place_name, origin: @ride.origin, origin_place_name: @ride.origin_place_name, requested_datetime: @ride.requested_datetime, state: @ride.state, type: @ride.type }
    end

    assert_redirected_to ride_request_path(assigns(:ride))
  end

  test "should show ride_request" do
    get :show, id: @ride
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ride
    assert_response :success
  end

  test "should update ride_request" do
    put :update, id: @ride, ride: { destination: @ride.destination, destination_place_name: @ride.destination_place_name, origin: @ride.origin, origin_place_name: @ride.origin_place_name, requested_datetime: @ride.requested_datetime, state: @ride.state, type: @ride.type }
    assert_redirected_to ride_request_path(assigns(:ride))
  end

  test "should destroy ride_request" do
    assert_difference('RideRequest.count', -1) do
      delete :destroy, id: @ride
    end

    assert_redirected_to ride_requests_path
  end
end
