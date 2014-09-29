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

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: payment
      expect(response.status).to be(200)
    end
  end

  describe 'GET #edit' do
    it 'gets a successful response' do
      get :edit, id: payment
      expect(response.status).to be(200)
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      @payment = FactoryGirl.create(:payment)
    end
    context 'with valid params' do
      it 'locates the requested @payment' do
        patch :update, id: @payment,
              payment: FactoryGirl.attributes_for(:payment)
        expect(assigns(:payment)).to eq(@payment)
      end
      it "changes @payment's attributes" do
        patch :update, id: @payment,
              payment: FactoryGirl.attributes_for(:payment, amount_cents: 500)
        @payment.reload
        expect(@payment.amount_cents).to eq(500)
      end
      it 'redirects to the updated content' do
        patch :update, id: @payment,
              payment: FactoryGirl.attributes_for(:payment)
        expect(response).to redirect_to @payment
      end
    end
  end
end
