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
end
