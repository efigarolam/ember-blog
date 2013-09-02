class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :posts, foreign_key: :author_id
  has_many :comments

  def self.from_omniauth(auth)
    if user = User.find_by(email: auth.info.email)
      user.provider = auth.provider
      user.uid = auth.uid
      user
    else
      total_users = User.count
      where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.admin = total_users == 0
        user.active = true
      end
    end
  end
end