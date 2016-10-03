class Post < ActiveRecord::Base
  include Voteable
  
  belongs_to :creator, foreign_key: "user_id", class_name: "User"
  has_many :comments
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :votes, as: :voteable

  validates :title, presence: true, length: {minimum: 5}
  validates :url, presence: true, uniqueness: true
  validates :description, presence: true

  before_save :generate_slug

  def to_param
    self.slug
  end

  def generate_slug
    new_slug = to_slug(self.title)

    # if a post with this slug exists, uniquify it
    post = Post.find_by slug: new_slug

    count = 2
    while post && post != self
      new_slug = append_suffix(new_slug, count)
      post = Post.find_by slug: new_slug
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