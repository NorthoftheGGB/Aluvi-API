require 'test_helper'

class FaresControllerTest < ActionController::TestCase
  setup do
    @fare = rides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fares)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ride" do
    assert_difference('Ride.count') do
      post :create, fare: { destination: @fare.destination, destination_place_name: @fare.destination_place_name, finished: @fare.finished, meeting_point: @fare.meeting_point, meeting_point_place_name: @fare.meeting_point_place_name, scheduled: @fare.scheduled, started: @fare.started, state: @fare.state }
    end

    assert_redirected_to ride_path(assigns(:fare))
  end

  test "should show ride" do
    get :show, id: @fare
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fare
    assert_response :success
  end

  test "should update ride" do
    put :update, id: @fare, fare: { destination: @fare.destination, destination_place_name: @fare.destination_place_name, finished: @fare.finished, meeting_point: @fare.meeting_point, meeting_point_place_name: @fare.meeting_point_place_name, scheduled: @fare.scheduled, started: @fare.started, state: @fare.state }
    assert_redirected_to ride_path(assigns(:fare))
  end

  test "should destroy ride" do
    assert_difference('Ride.count', -1) do
      delete :destroy, id: @fare
    end

    assert_redirected_to rides_path
  end
end
