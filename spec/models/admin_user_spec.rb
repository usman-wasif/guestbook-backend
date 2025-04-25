require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  it 'is valid with a username and password' do
    admin = AdminUser.new(username: 'admin', password: 'password123')
    expect(admin).to be_valid
  end

  it 'is invalid without a username' do
    admin = AdminUser.new(username: nil)
    expect(admin).not_to be_valid
  end
end