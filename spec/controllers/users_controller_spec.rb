describe UsersController do
  let(:user) {FactoryGirl.create(:user)}

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

  describe 'GET #new' do
    it 'gets a successful response' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'saves a new user to the database' do
        expect{
          post :create, user: FactoryGirl.attributes_for(:user)
        }.to change(User, :count).by(1)
      end
      context 'if user is not interested in being a driver' do
        it 'redirects to users#show' do
          post :create, user: FactoryGirl.attributes_for(:user)
          expect(response).to redirect_to user_path(assigns(:user))
        end
      end
      context 'if user is interested in being a driver' do
        it 'redirects to drivers#edit' do
          post :create, user: FactoryGirl.attributes_for(:user_interested_in_being_driver)
          expect(response).to redirect_to edit_driver_path(assigns(:user).as_driver)
        end
      end
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, id: user
      expect(response.status).to be(200)
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, id: user
      expect(response.status).to be(200)
    end
  end
end
