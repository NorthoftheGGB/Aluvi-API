describe RidesController do
  let(:ride) {FactoryGirl.create(:on_demand_ride)}

  describe 'GET #index' do
    it 'gets a successful response' do
      get :index
      expect(response.status).to be(200)
    end
    it 'assigns a @rides variable' do
      get :index
      expect(assigns(:rides)).to_not be(nil)
    end
  end
end
