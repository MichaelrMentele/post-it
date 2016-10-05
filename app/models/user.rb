class User < ActiveRecord::Base
  include Sluggable

  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validations: false
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  sluggable_column :username

  def send_pin_to_twilio
    account_sid = 'AC0016f4c55afaf79b77ec86e2bf32ec19'
    auth_token = '36077868d84cb02d517eb5d02199c08b'

    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new account_sid, auth_token
    msg = 'Your pin is ' + self.pin.to_s
    client.account.messages.create({
        :to => '12066184282',
        :from => '14255288374',
        :body => msg,
    })
  end

  def remove_pin!
    self.update_column(:pin, nil)
  end

  def generate_pin!
    self.update_column(:pin, rand(10 ** 6)) # random 6 digit number
  end

  def two_factor_auth?
    !self.phone.blank?
  end

  def admin?
    self.roles == 'admin'
  end

  def moderator?
    self.roles == 'moderator'
  end
end