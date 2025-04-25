require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'GET #index' do
    it 'returns the last 50 non-spam comments' do
      60.times { |i| Comment.create!(name: "User #{i}", message: "Comment #{i}") }
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(50)
    end
  end

  describe 'POST #create' do
    it 'creates a new comment and broadcasts it' do
      expect {
        post :create, params: { comment: { name: 'John', message: 'Hello!' } }
      }.to change(Comment, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns errors for invalid comments' do
      post :create, params: { comment: { name: '', message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Message can't be blank")
    end

    it 'broadcasts the new comment via ActionCable' do
      expect(ActionCable.server).to receive(:broadcast).with('comments_channel', instance_of(Comment))
      post :create, params: { comment: { name: 'John', message: 'Hello!' } }
    end
  end
end