describe CarsController do

  let(:car) {FactoryGirl.create(:car)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable cars' do
      get :index
      expect(assigns(:cars)).to_not be(nil)
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

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: car
      expect(response.status).to equal(200)
    end
  end

  describe 'PATCH #update' do
    before :each do
      @car = FactoryGirl.create(:car, license_plate: 'EE9369')
    end
    context 'with valid parameters' do
      it 'locates the requested @car' do
        patch :update, id: @car, car: FactoryGirl.attributes_for(:car)
        expect(assigns(:car)).to eq(@car)
      end
      it "changes @car's attributes" do
        patch :update, id: @car,
                car: FactoryGirl.attributes_for(:car, license_plate: 'EE9369')
        @car.reload
        expect(@car.license_plate).to eq('EE9369')
      end
      it "redirects to the updated content" do
        patch :update, id: @car, car: FactoryGirl.attributes_for(:car)
        expect(response).to redirect_to @car
      end
    end
  end
end
