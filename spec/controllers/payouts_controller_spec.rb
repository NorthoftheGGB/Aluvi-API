describe PayoutsController do
  let(:payout) {FactoryGirl.create(:payout)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to be(200)
    end
    it 'assigns a variable @payouts' do
      get :index
      expect(assigns(:payouts)).to_not be(nil)
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
      it 'creates a new payout to the database' do
        expect{
          post :create, payout: FactoryGirl.attributes_for(:payout)
        }.to change(Payout, :count).by(1)
      end
      it 'redirects to the payouts#show' do
        post :create, payout: FactoryGirl.attributes_for(:payout)
        expect(response).to redirect_to payout_path(assigns(:payout))
      end
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, id: payout
      expect(response.status).to be(200)
    end
  end
end
