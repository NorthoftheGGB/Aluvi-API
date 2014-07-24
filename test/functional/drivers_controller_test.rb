require 'test_helper'

class DriversControllerTest < ActionController::TestCase
  setup do
    @driver = User.new 
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:drivers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create driver" do
    assert_difference('User.count') do
      post :create, driver: { commuter_balance_cents: @driver.commuter_balance_cents, commuter_refill_amount_cents: @driver.commuter_refill_amount_cents, company_id: @driver.company_id, first_name: @driver.first_name, is_driver: @driver.is_driver, is_driver: @driver.is_driver, last_name: @driver.last_name, stripe_customer_id: @driver.stripe_customer_id, stripe_recipient_id: @driver.stripe_recipient_id }
    end

    assert_redirected_to driver_path(assigns(:driver))
  end

  test "should show driver" do
    get :show, id: @driver
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @driver
    assert_response :success
  end

  test "should update driver" do
    put :update, id: @driver, driver: { commuter_balance_cents: @driver.commuter_balance_cents, commuter_refill_amount_cents: @driver.commuter_refill_amount_cents, company_id: @driver.company_id, first_name: @driver.first_name, is_driver: @driver.is_driver, is_driver: @driver.is_driver, last_name: @driver.last_name, stripe_customer_id: @driver.stripe_customer_id, stripe_recipient_id: @driver.stripe_recipient_id }
    assert_redirected_to driver_path(assigns(:driver))
  end

  test "should destroy driver" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @driver
    end

    assert_redirected_to drivers_path
  end

	def test_should_successfully_import_csv
		csv_rows = <<-eos
first_name,email
Name1,name1@example.com
Name2,name2@example.com
Name3,name3@example.com
		eos

		file = Tempfile.new('new_drivers.csv')
		file.write(csv_rows)
		file.rewind

		assert_difference "User.count", 3 do
			post :csv_import, :file => Rack::Test::UploadedFile.new(file, 'text/csv')
		end

		assert_redirected_to :action => "index", :notice => "Successfully imported the CSV file."
		#assert_equal "Successfully imported the CSV file.", flash[:notice]
	end
end
