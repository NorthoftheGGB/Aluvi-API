describe DriversController do
  let(:driver) {FactoryGirl.create(:interested_driver)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable drivers' do
      get :index
      expect(assigns(:drivers)).to_not be(nil)
    end
  end

  describe 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to equal(200)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'saves the new driver to the database' do
        expect{
          post :create, driver: FactoryGirl.attributes_for(:interested_driver)
        }.to change(Driver, :count).by(1)
      end
      it 'redirects to drivers#show' do
        post :create, driver: FactoryGirl.attributes_for(:interested_driver)
        expect(response).to redirect_to driver_path(assigns(:driver))
      end
    end
  end

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: driver
      expect(response.status).to equal(200)
    end
  end

  describe 'GET #edit' do
    it 'gets a successful response' do
      get :edit, id: driver
      expect(response.status).to equal(200)
    end
  end

  describe 'PATCH #update' do
    before :each do
      @driver = FactoryGirl.create(:interested_driver, first_name: "Jane")
    end
    context 'with valid parameters' do
      it 'locates the requested @driver' do
        patch :update, id: @driver, driver: FactoryGirl.attributes_for(:interested_driver)
        expect(assigns(:driver)).to eq(@driver)
      end
      it "changes @driver's attributes" do
        patch :update, id: @driver,
                driver: FactoryGirl.attributes_for(:interested_driver, first_name: 'Jane')
        @driver.reload
        expect(@driver.first_name).to eq('Jane')
      end
      it "redirects to the updated content" do
        patch :update, id: @driver, driver: FactoryGirl.attributes_for(:driver)
        expect(response).to redirect_to @driver
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @driver = FactoryGirl.create(:interested_driver)
    end
    it 'deletes the driver' do
      expect{delete :destroy, id: @driver}.to change(Driver, :count).by(-1)
    end
    it 'redirects to driver#index' do
      delete :destroy, id: @driver
      expect(response).to redirect_to drivers_path
    end
  end
end
