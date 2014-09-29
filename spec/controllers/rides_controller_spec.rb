describe RidesController do
  let(:ride) {FactoryGirl.create(:on_demand_ride)}

  describe 'GET #index' do
    it 'gets a successful response' do
      get :index
      expect(response.status).to be(200)
    end
    it 'assigns a @rides variable' do
      get :index
      expect(assigns(:rides)).to_not be(nil)
    end
  end

  describe 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to be(200)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new ride' do
        expect{
          post :create, ride: FactoryGirl.attributes_for(:on_demand_ride)
        }.to change(Ride, :count).by(1)
      end
      it 'redirects to rides#show' do
        post :create, ride: FactoryGirl.attributes_for(:on_demand_ride)
        expect(response).to redirect_to ride_path(assigns(:ride))
      end
    end
  end
end
