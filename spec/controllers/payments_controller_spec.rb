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
end
