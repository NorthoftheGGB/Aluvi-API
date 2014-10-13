describe UsersController do
  let(:user) {FactoryGirl.create(:rider)}

  describe 'GET #index' do
    it 'gets a successful response' do
      get :index
      expect(response.status).to eq(200)
    end
    it 'assigns an instance variable users' do
      get :index
      expect(assigns(:users)).to_not be(nil)
    end
  end
end
