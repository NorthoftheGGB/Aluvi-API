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
end
