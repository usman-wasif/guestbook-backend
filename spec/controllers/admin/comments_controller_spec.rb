require 'rails_helper'

RSpec.describe Admin::CommentsController, type: :controller do
  let!(:admin) do
    admin = AdminUser.new(username: 'admin')
    admin.password = 'password123'
    admin.save!
    admin
  end

  let!(:comment) { Comment.create!(name: 'John', message: 'Hello!') }

  let(:jwt_token) do
    payload = { admin_id: admin.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, ENV['JWT_SECRET'], 'HS256')
  end

  before do
    ENV['JWT_SECRET'] ||= 'test_jwt_secret_32_chars_minimum'
  end

  describe 'POST #login' do
    it 'logs in an admin with valid credentials and returns a JWT' do
      post :login, params: { username: 'admin', password: 'password123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged in successfully')
      expect(JSON.parse(response.body)['token']).to be_present
      expect(session[:admin_user_id]).to eq(admin.id)
    end

    it 'returns 401 for invalid credentials' do
      post :login, params: { username: 'admin', password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid username or password')
      expect(session[:admin_user_id]).to be_nil
    end
  end

  describe 'DELETE #logout' do
    before do
      post :login, params: { username: 'admin', password: 'password123' }
    end

    it 'logs out the admin' do
      delete :logout
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
      expect(session[:admin_user_id]).to be_nil
    end
  end

  describe 'GET #index' do
    context 'with session-based authentication' do
      before do
        post :login, params: { username: 'admin', password: 'password123' }
      end

      it 'returns all comments for a logged-in admin' do
        3.times { |i| Comment.create!(name: "User #{i}", message: "Comment #{i}") }
        get :index
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq(4)
      end

      it 'returns 401 unauthorized if not logged in' do
        delete :logout
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'with JWT authentication' do
      it 'returns all comments for a logged-in admin' do
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        3.times { |i| Comment.create!(name: "User #{i}", message: "Comment #{i}") }
        get :index
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq(4)
      end

      it 'returns 401 for an invalid token' do
        request.headers['Authorization'] = "Bearer invalid_token"
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid or expired token')
      end
    end
  end

  describe 'PATCH #mark_spam' do
    context 'with session-based authentication' do
      before do
        post :login, params: { username: 'admin', password: 'password123' }
      end

      it 'marks a comment as spam' do
        patch :mark_spam, params: { id: comment.id }
        expect(response).to have_http_status(:success)
        expect(comment.reload.is_spam).to be true
      end

      it 'returns 404 if the comment does not exist' do
        patch :mark_spam, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with JWT authentication' do
      it 'marks a comment as spam' do
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        patch :mark_spam, params: { id: comment.id }
        expect(response).to have_http_status(:success)
        expect(comment.reload.is_spam).to be true
      end

      it 'returns 401 for an invalid token' do
        request.headers['Authorization'] = "Bearer invalid_token"
        patch :mark_spam, params: { id: comment.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid or expired token')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with session-based authentication' do
      before do
        post :login, params: { username: 'admin', password: 'password123' }
      end

      it 'deletes a comment' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change(Comment, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'returns 404 if the comment does not exist' do
        delete :destroy, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with JWT authentication' do
      it 'deletes a comment' do
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change(Comment, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it 'returns 401 for an invalid token' do
        request.headers['Authorization'] = "Bearer invalid_token"
        delete :destroy, params: { id: comment.id }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Invalid or expired token')
      end
    end
  end

end