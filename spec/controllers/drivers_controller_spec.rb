describe DriversController do
  let(:driver) {FactoryGirl.create(:driver)}

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
          post :create, driver: FactoryGirl.attributes_for(:driver)
        }.to change(Driver, :count).by(1)
      end
      it 'redirects to drivers#show' do
        post :create, driver: FactoryGirl.attributes_for(:driver)
        expect(response).to redirect_to driver_path(assigns(:driver))
      end
    end
  end
end
