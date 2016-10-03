class Category < ActiveRecord::Base
  has_many :post_categories
  has_many :posts, through: :post_categories

  validates :name, presence: true

  before_save :generate_slug

  def to_param
    self.slug
  end

  def generate_slug
    new_slug = to_slug(self.name)

    # if a cat with this slug exists, uniquify it
    cat = Category.find_by slug: new_slug

    count = 2
    while cat && cat != self
      new_slug = append_suffix(new_slug, count)
      cat = Category.find_by slug: new_slug
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