describe DevicesController do
  let(:device) {FactoryGirl.create(:device)}

  describe "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable devices' do
      get :index
      expect(assigns(:devices)).to_not be(nil)
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
      it 'saves the new device to the database' do
        expect{
          post :create, device: FactoryGirl.attributes_for(:device)
        }.to change(Device, :count).by(1)
      end
      it 'redirects to devices#show' do
        post :create, device: FactoryGirl.attributes_for(:device)
        expect(response).to redirect_to device_path(assigns(:device))
      end
    end
  end

  describe 'GET #show' do
    it 'gets a successful response' do
      get :show, id: device
      expect(response.status).to equal(200)
    end
  end
end
