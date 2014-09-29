describe PaymentsController do
  let(:payment) {FactoryGirl.create(:payment)}

  describe 'GET #index' do
    it 'gets a successful response' do
      get :index
      expect(response.status).to eq(200)
    end
    it 'assigns an instance variable payments' do
      get :index
      expect(assigns(:payments)).to_not be(nil)
    end
  end

  describe 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'saves a new payment to the database' do
        expect{
          post :create, payment: FactoryGirl.attributes_for(:payment)
        }.to change(Payment, :count).by(1)
      end
      it 'redirects to payments#show' do
        post :create, payment: FactoryGirl.attributes_for(:payment)
        expect(response).to redirect_to payment_path(assigns(:payment))
      end
    end
  end


end
