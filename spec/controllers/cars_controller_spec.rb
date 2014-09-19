describe CarsController do
  context "GET #index" do
    it 'gets a successful response' do
      get :index
      expect(response.status).to equal(200)
    end
    it 'assigns an instance variable cars' do
      get :index
      expect(assigns(:cars)).to_not be(nil)
    end
  end
  context 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to equal(200)
    end
  end
end
