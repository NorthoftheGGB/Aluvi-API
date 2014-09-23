describe FaresController do
  let(:fare) {FactoryGirl.create(:fare)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable fares' do
      get :index
      expect(assigns(:fares)).to_not be(nil)
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
      it 'saves the new fare to the database' do
        expect{
          post :create, fare: FactoryGirl.attributes_for(:fare)
        }.to change(Fare, :count).by(1)
      end
      it 'redirects to fares#show' do
        post :create, fare: FactoryGirl.attributes_for(:fare)
        expect(response).to redirect_to fare_path(assigns(:fare))
      end
    end
  end

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: fare
      expect(response.status).to equal(200)
    end
  end
end
