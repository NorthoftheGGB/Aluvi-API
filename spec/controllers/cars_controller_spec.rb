describe CarsController do
  context "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable cars' do
      get :index
      expect(assigns(:cars)).to_not be(nil)
    end
  end
  context 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to equal(200)
    end
  end
  describe 'POST #create' do
    context 'with valid parameters' do
      it 'saves the new car to the database' do
        expect{
          post :create, car: FactoryGirl.attributes_for(:car)
        }.to change(Car, :count).by(1)
      end
      it 'redirects to cars#show' do
        post :create, car: FactoryGirl.attributes_for(:car)
        expect(response).to redirect_to car_path(assigns(:car))
      end
    end
  end
end
