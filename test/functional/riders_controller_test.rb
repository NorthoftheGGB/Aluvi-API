require 'test_helper'

class RidersControllerTest < ActionController::TestCase
  setup do
    @rider = User.new 
		@rider.save
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:riders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rider" do
    assert_difference('User.count') do
      post :create, rider: { commuter_balance_cents: @rider.commuter_balance_cents, commuter_refill_amount_cents: @rider.commuter_refill_amount_cents, company_id: @rider.company_id, first_name: @rider.first_name, last_name: @rider.last_name, stripe_customer_id: @rider.stripe_customer_id, stripe_recipient_id: @rider.stripe_recipient_id }
    end

    assert_redirected_to rider_path(assigns(:rider))
  end

  test "should show rider" do
    get :show, id: @rider
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rider
    assert_response :success
  end

  test "should update rider" do
    put :update, id: @rider, rider: { commuter_balance_cents: @rider.commuter_balance_cents, commuter_refill_amount_cents: @rider.commuter_refill_amount_cents, company_id: @rider.company_id, first_name: @rider.first_name, last_name: @rider.last_name, stripe_customer_id: @rider.stripe_customer_id, stripe_recipient_id: @rider.stripe_recipient_id }
    assert_redirected_to rider_path(assigns(:rider))
  end

  test "should destroy rider" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @rider
    end

    assert_redirected_to riders_path
  end

	def test_should_successfully_import_csv
		csv_rows = <<-eos
first_name,email
Name1,name1@example.com
Name2,name2@example.com
Name3,name3@example.com
		eos

		file = Tempfile.new('new_riders.csv')
		file.write(csv_rows)
		file.rewind

		assert_difference "User.count", 3 do
			post :csv_import, :file => Rack::Test::UploadedFile.new(file, 'text/csv')
		end

		assert_redirected_to :action => "index", :notice => "Successfully imported the CSV file."
		#assert_equal "Successfully imported the CSV file.", flash[:notice]
	end
end
