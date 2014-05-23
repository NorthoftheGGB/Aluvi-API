require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { commuter_balance_cents: @user.commuter_balance_cents, commuter_refill_amount_cents: @user.commuter_refill_amount_cents, company_id: @user.company_id, first_name: @user.first_name, is_driver: @user.is_driver, is_rider: @user.is_rider, last_known_location: @user.last_known_location, last_name: @user.last_name, state: @user.state, stripe_customer_id: @user.stripe_customer_id, stripe_recipient_id: @user.stripe_recipient_id }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { commuter_balance_cents: @user.commuter_balance_cents, commuter_refill_amount_cents: @user.commuter_refill_amount_cents, company_id: @user.company_id, first_name: @user.first_name, is_driver: @user.is_driver, is_rider: @user.is_rider, last_known_location: @user.last_known_location, last_name: @user.last_name, state: @user.state, stripe_customer_id: @user.stripe_customer_id, stripe_recipient_id: @user.stripe_recipient_id }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
