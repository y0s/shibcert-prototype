class User < ActiveRecord::Base
  belongs_to :role
  has_many :certs

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      info = auth['info']
      user.name = info['name'] || user.uid
      user.email = info['email']
    end
  end
end
