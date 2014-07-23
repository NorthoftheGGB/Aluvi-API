require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  setup do
    @offer = offered_rides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offered_ride" do
    assert_difference('OfferedRide.count') do
      post :create, offer: { driver_id: @offer.driver_id, rider_id: @offer.rider_id }
    end

    assert_redirected_to offered_ride_path(assigns(:offer))
  end

  test "should show offered_ride" do
    get :show, id: @offer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offer
    assert_response :success
  end

  test "should update offered_ride" do
    put :update, id: @offer, offer: { driver_id: @offer.driver_id, rider_id: @offer.rider_id }
    assert_redirected_to offered_ride_path(assigns(:offer))
  end

  test "should destroy offered_ride" do
    assert_difference('OfferedRide.count', -1) do
      delete :destroy, id: @offer
    end

    assert_redirected_to offered_rides_path
  end
end
