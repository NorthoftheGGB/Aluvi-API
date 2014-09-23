describe RidersController do
  let(:rider) {FactoryGirl.create(:rider)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable riders' do
      get :index
      expect(assigns(:riders)).to_not be(nil)
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
      it 'saves the new rider to the database' do
        expect{
          post :create, rider: FactoryGirl.attributes_for(:rider)
        }.to change(Rider, :count).by(1)
      end
      it 'redirects to riders#show' do
        post :create, rider: FactoryGirl.attributes_for(:rider)
        expect(response).to redirect_to rider_path(assigns(:rider))
      end
    end
  end

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: rider
      expect(response.status).to equal(200)
    end
  end
end
