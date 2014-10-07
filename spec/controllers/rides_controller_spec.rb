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

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: ride
      expect(response.status).to be(200)
    end
  end

  describe 'GET #edit' do
    it 'gets a successful response' do
      get :edit, id: ride
      expect(response.status).to be(200)
    end
  end

  describe 'PATCH #update' do
    before(:each) {@ride = FactoryGirl.create(:on_demand_ride)}
    context 'with valid params' do
      it 'locates the requested @ride' do
        patch :update, id: @ride, ride: FactoryGirl.attributes_for(:on_demand_ride)
        expect(assigns(:ride)).to eq(@ride)
      end
      it "changes the ride's attributes" do
        patch :update, id: @ride,
              ride: FactoryGirl.attributes_for(:on_demand_ride, destination_place_name: "Empire State Building")
        @ride.reload
        expect(@ride.destination_place_name).to eq("Empire State Building")
      end
      it 'redirects to ride#show' do
        patch :update, id: @ride, ride: FactoryGirl.attributes_for(:on_demand_ride)
        expect(response).to redirect_to @ride
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) {@ride = FactoryGirl.create(:ride)}
    it 'deletes the ride from the database' do
      expect{
        delete :destroy, id: @ride
      }.to change(Ride, :count).by(-1)
    end
    it 'redirects to rides#index' do
      delete :destroy, id: @ride
      expect(response).to redirect_to rides_path
    end
  end
end
