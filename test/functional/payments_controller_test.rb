require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase
  setup do
    @payment = FactoryGirl.create(:payment)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment" do
    assert_difference('Payment.count') do
      post :create, payment: { amount_cents: @payment.amount_cents, captured_at: @payment.captured_at, driver_id: @payment.driver_id, fare_id: @payment.fare_id, initiation: @payment.initiation, ride_id: @payment.ride_id, rider_id: @payment.rider_id, stripe_charge_status: @payment.stripe_charge_status }
    end

    assert_redirected_to payment_path(assigns(:payment))
  end

  test "should show payment" do
    get :show, id: @payment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @payment
    assert_response :success
  end

  test "should update payment" do
    put :update, id: @payment, payment: { amount_cents: @payment.amount_cents, captured_at: @payment.captured_at, driver_id: @payment.driver_id, fare_id: @payment.fare_id, initiation: @payment.initiation, ride_id: @payment.ride_id, rider_id: @payment.rider_id, stripe_charge_status: @payment.stripe_charge_status }
    assert_redirected_to payment_path(assigns(:payment))
  end

  test "should destroy payment" do
    assert_difference('Payment.count', -1) do
      delete :destroy, id: @payment
    end

    assert_redirected_to payments_path
  end
end
