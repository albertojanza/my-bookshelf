#TODO internationalization, title in different languages, books available in different languages
class Book < ActiveRecord::Base
  #has_one :adventure, :as => :resource
  has_many :experiences

  validates :title, :presence => true
  validates :author, :presence => true
  validates :asin, :presence => true

#  after_create :create_adventure
  before_save :create_permalink

  serialize :author

  def create_permalink
    self.permalink = "#{self.title}-#{self.author}".parameterize
  end

#  def create_adventure
#    Adventure.create :resource => self
#  end

 def to_param
   permalink
 end

  def self.find_by_asin(*args) 
    book = super(*args)
    if book.nil?
      puts args[0]

      client = ASIN::Client.instance
      amazon_book = client.lookup args[0]
      unless amazon_book.empty?
        Book.create do |book| 
          book.asin =  args[0]
          book.author = amazon_book[0].raw.ItemAttributes.Author
          book.title = amazon_book[0].raw.ItemAttributes.Title
          book.detail_page_url = amazon_book[0].raw.DetailPageURL
          book.ean = amazon_book[0].raw.ItemAttributes.EAN
          #book.edition = amazon_book[0].raw.ItemAttributes.Edition
          book.isbn = amazon_book[0].raw.ItemAttributes.ISBN
          book.number_of_pages= amazon_book[0].raw.ItemAttributes.NumberOfPages
          book.product_group = amazon_book[0].raw.ItemAttributes.ProductGroup
          book.studio = amazon_book[0].raw.ItemAttributes.Studio
          book.publisher = amazon_book[0].raw.ItemAttributes.Publisher
          book.publication_date = amazon_book[0].raw.ItemAttributes.PublicationDate
          book.medium_image = ( amazon_book[0].raw.ImageSets.ImageSet.class.eql?(Array) ? amazon_book[0].raw.ImageSets.ImageSet[0].MediumImage.URL : amazon_book[0].raw.ImageSets.ImageSet.MediumImage.URL)
          book.tiny_image = ( amazon_book[0].raw.ImageSets.ImageSet.class.eql?(Array) ? amazon_book[0].raw.ImageSets.ImageSet[0].TinyImage.URL : amazon_book[0].raw.ImageSets.ImageSet.TinyImage.URL)
          book.large_image = ( amazon_book[0].raw.ImageSets.ImageSet.class.eql?(Array) ? amazon_book[0].raw.ImageSets.ImageSet[0].LargeImage.URL : amazon_book[0].raw.ImageSets.ImageSet.LargeImage.URL)
          book.thumbnail_image = ( amazon_book[0].raw.ImageSets.ImageSet.class.eql?(Array) ? amazon_book[0].raw.ImageSets.ImageSet[0].ThumbnailImage.URL : amazon_book[0].raw.ImageSets.ImageSet.ThumbnailImage.URL)
        end
      end
      book = super(*args)
    end
    book
  end

  def people_have_read
    #Experience.joins(:user => :authentications).where(:adventure_id => self.adventure.id)
    users_with_this_experience(0)
  end

  def people_are_reading
    users_with_this_experience(1)
  end

  def people_will_read
    users_with_this_experience(2)
  end

private 
  def users_with_this_experience(code)
    book_cache = Rails.cache.fetch("book_#{self.id}") || {}
    if book_cache.empty? || book_cache["ex_#{code}"].nil?
      book_cache["ex_#{code}"] = User.joins(:experiences).where('experiences.book_id = ? AND code = ?', self.id,code).map {|auth| auth.uid }
      Rails.cache.write "book_#{self.id}", book_cache
    end
    book_cache["ex_#{code}"]
  end
end
