class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validations: false
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  before_save :generate_slug

  def to_param
    self.slug
  end

  def generate_slug
    new_slug = to_slug(self.username)

    # if a user with this slug exists, uniquify it
    user = User.find_by slug: new_slug

    count = 2
    while user && user != self
      new_slug = append_suffix(new_slug, count)
      user = User.find_by slug: new_slug
      count += 1
    end

    self.slug = new_slug
  end

  def append_suffix(str, count)
    if str.split('-').last.to_i != 0
      return str.split("-").slice(0...-1).join("-") + "-" + count.to_s
    else
      return str + "-" count.to_s
    end
  end

  def to_slug(name)
    str = name.strip.downcase
    str.gsub!(/\s*[^a-z0-9]\s*/, "-")
    str.gsub!(/-+/, "-")
    return str
  end
end