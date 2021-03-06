describe OffersController do
  let(:offer) {FactoryGirl.create(:offer)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable offers' do
      get :index
      expect(assigns(:offers)).to_not be(nil)
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
      let!(:offer_params) {{driver_id: offer.driver_id, fare_id: offer.fare_id}}
      it 'saves the new offer to the database' do
        expect{
          post :create, offer: offer_params
        }.to change(Offer, :count).by(1)
      end
      it 'redirects to offers#show' do
        post :create, offer: offer_params
        expect(response).to redirect_to offer_path(assigns(:offer))
      end
    end
  end

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: offer
      expect(response.status).to equal(200)
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @offer = offer
    end
    it 'deletes the offer' do
      expect{delete :destroy, id: @offer}.to change(Offer, :count).by(-1)
    end
    it 'redirects to offer#index' do
      delete :destroy, id: @offer
      expect(response).to redirect_to offers_path
    end
  end
end
