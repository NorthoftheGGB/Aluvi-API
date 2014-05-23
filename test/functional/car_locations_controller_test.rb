require 'test_helper'

class CarLocationsControllerTest < ActionController::TestCase
  setup do
    @car_location = car_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:car_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create car_location" do
    assert_difference('CarLocation.count') do
      post :create, car_location: { last_known_location: @car_location.last_known_location, references: @car_location.references }
    end

    assert_redirected_to car_location_path(assigns(:car_location))
  end

  test "should show car_location" do
    get :show, id: @car_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @car_location
    assert_response :success
  end

  test "should update car_location" do
    put :update, id: @car_location, car_location: { last_known_location: @car_location.last_known_location, references: @car_location.references }
    assert_redirected_to car_location_path(assigns(:car_location))
  end

  test "should destroy car_location" do
    assert_difference('CarLocation.count', -1) do
      delete :destroy, id: @car_location
    end

    assert_redirected_to car_locations_path
  end
end
