 require 'test_helper'

class RidesControllerTest < ActionController::TestCase
  setup do
    @ride = FactoryGirl.create(:commuter_ride)
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

  test "should create ride" do
		assert_difference('Ride.count') do
			post :create, ride: { destination: @ride.destination, destination_place_name: @ride.destination_place_name, origin: @ride.origin, origin_place_name: @ride.origin_place_name, requested_datetime: @ride.requested_datetime, state: @ride.state, request_type: @ride.request_type, rider_id: @ride.rider.id }
    end

    assert_redirected_to ride_path(assigns(:ride))
  end

  test "should show ride" do
    get :show, id: @ride
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ride
    assert_response :success
  end

  test "should update ride" do
    put :update, id: @ride, ride: { destination: @ride.destination, destination_place_name: @ride.destination_place_name, origin: @ride.origin, origin_place_name: @ride.origin_place_name, requested_datetime: @ride.requested_datetime, state: @ride.state, request_type: @ride.request_type }
    assert_redirected_to ride_path(assigns(:ride))
  end

  test "should destroy ride" do
    assert_difference('Ride.count', -1) do
      delete :destroy, id: @ride
    end

    assert_redirected_to rides_path
  end
end
