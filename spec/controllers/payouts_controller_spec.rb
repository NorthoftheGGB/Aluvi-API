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

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, id: payout
      expect(response.status).to be(200)
    end
  end

  describe 'PATCH #update' do
    before(:each) {@payout = FactoryGirl.create(:payout)}

    context 'with valid params' do
      it 'locates the requested payout' do
        patch :update, id: @payout, payout: FactoryGirl.attributes_for(:payout)
        expect(assigns(:payout)).to eq(@payout)
      end
      it "updates @payout's attributes" do
        patch :update, id: @payout, payout: FactoryGirl.attributes_for(:payout, amount_cents: 300)
        @payout.reload
        expect(@payout.amount_cents).to be(300)
      end
      it 'redirects to payout#show' do
        patch :update, id: @payout, payout: FactoryGirl.attributes_for(:payout)
        expect(response).to redirect_to @payout
      end
    end

    describe 'DELETE #destroy' do
      let!(:payout) {FactoryGirl.create(:payout)}

      it 'deletes the payout from the database' do
        expect{
          delete :destroy, id: payout
          }.to change(Payout, :count).by(-1)
      end
      it 'redirects back to payouts#index' do
        delete :destroy, id: payout
        expect(response).to redirect_to payouts_path
      end
    end
  end
end
