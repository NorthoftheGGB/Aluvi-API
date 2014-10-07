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

  describe 'GET #edit' do
    it 'gets a successful response' do
      get :edit, id: fare
      expect(response.status).to equal(200)
    end
  end

  describe 'PATCH #update' do
    before :each do
      @fare = FactoryGirl.create(:scheduled_fare)
    end
    context 'with valid parameters' do
      it 'locates the requested @fare' do
        patch :update, id: @fare, fare: FactoryGirl.attributes_for(:scheduled_fare)
        expect(assigns(:fare)).to eq(@fare)
      end
      it "changes @fare's attributes" do
        patch :update, id: @fare,
                fare: FactoryGirl.attributes_for(:scheduled_fare, state: 'completed')
        @fare.reload
        expect(@fare.state).to eq('completed')
      end
      it "redirects to the updated content" do
        patch :update, id: @fare, fare: FactoryGirl.attributes_for(:fare)
        expect(response).to redirect_to @fare
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @fare = FactoryGirl.create(:fare)
    end
    it 'deletes the fare' do
      expect{delete :destroy, id: @fare}.to change(Fare, :count).by(-1)
    end
    it 'redirects to fare#index' do
      delete :destroy, id: @fare
      expect(response).to redirect_to fares_path
    end
  end
end
