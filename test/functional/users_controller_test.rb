require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = User.new 
		@user.save
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
      post :create, user: { commuter_balance_cents: @user.commuter_balance_cents, commuter_refill_amount_cents: @user.commuter_refill_amount_cents, company_id: @user.company_id, first_name: @user.first_name, last_name: @user.last_name, stripe_customer_id: @user.stripe_customer_id, stripe_recipient_id: @user.stripe_recipient_id }
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
    put :update, id: @user, user: { commuter_balance_cents: @user.commuter_balance_cents, commuter_refill_amount_cents: @user.commuter_refill_amount_cents, company_id: @user.company_id, first_name: @user.first_name,last_name: @user.last_name, stripe_customer_id: @user.stripe_customer_id, stripe_recipient_id: @user.stripe_recipient_id }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end

	def test_should_successfully_import_csv
		csv_rows = <<-eos
first_name,email
Name1,name1@example.com
Name2,name2@example.com
Name3,name3@example.com
		eos

		file = Tempfile.new('new_users.csv')
		file.write(csv_rows)
		file.rewind

		assert_difference "User.count", 3 do
			post :csv_import, :file => Rack::Test::UploadedFile.new(file, 'text/csv')
		end

		assert_redirected_to :action => "index", :notice => "Successfully imported the CSV file."
		#assert_equal "Successfully imported the CSV file.", flash[:notice]
	end
end
