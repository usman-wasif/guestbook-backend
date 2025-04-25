require 'rails_helper'

RSpec.describe AdminPanel::CommentsController, type: :controller do
  let!(:admin) do
    admin = Admin.new(username: 'admin')
    admin.password = 'password123'
    admin.save!
    admin
  end

  let!(:comment) { Comment.create!(name: 'John', message: 'Hello!') }

  before do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password123')
  end

  describe 'GET #index' do
    it 'returns all comments for an authenticated admin' do
      3.times { |i| Comment.create!(name: "User #{i}", message: "Comment #{i}") }
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(4)
    end

    it 'returns 401 unauthorized for unauthenticated requests' do
      request.env['HTTP_AUTHORIZATION'] = nil
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH #mark_spam' do
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

  describe 'DELETE #destroy' do
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
end