require 'test_helper'

class RideRequestsControllerTest < ActionController::TestCase
  setup do
    @ride_request = ride_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ride_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ride_request" do
    assert_difference('RideRequest.count') do
      post :create, ride_request: { destination: @ride_request.destination, destination_place_name: @ride_request.destination_place_name, origin: @ride_request.origin, origin_place_name: @ride_request.origin_place_name, requested_datetime: @ride_request.requested_datetime, state: @ride_request.state, type: @ride_request.type }
    end

    assert_redirected_to ride_request_path(assigns(:ride_request))
  end

  test "should show ride_request" do
    get :show, id: @ride_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ride_request
    assert_response :success
  end

  test "should update ride_request" do
    put :update, id: @ride_request, ride_request: { destination: @ride_request.destination, destination_place_name: @ride_request.destination_place_name, origin: @ride_request.origin, origin_place_name: @ride_request.origin_place_name, requested_datetime: @ride_request.requested_datetime, state: @ride_request.state, type: @ride_request.type }
    assert_redirected_to ride_request_path(assigns(:ride_request))
  end

  test "should destroy ride_request" do
    assert_difference('RideRequest.count', -1) do
      delete :destroy, id: @ride_request
    end

    assert_redirected_to ride_requests_path
  end
end
