require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'is valid with a name and message' do
    comment = Comment.new(name: 'John', message: 'Hello!')
    expect(comment).to be_valid
  end

  it 'is invalid without a message' do
    comment = Comment.new(message: nil)
    expect(comment).not_to be_valid
  end

  it 'is invalid without a name' do
    comment = Comment.new(name: nil, message: 'Hello!')
    expect(comment).not_to be_valid
  end

end