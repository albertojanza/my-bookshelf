#TODO internationalization, title in different languages, books available in different languages
class Book < ActiveRecord::Base
  has_one :adventure, :as => :resource

  validates :title, :presence => true
  validates :author, :presence => true
  validates :asin, :presence => true

  after_create :create_adventure
  before_save :create_permalink

  def create_permalink
    self.permalink = "#{self.title}-#{self.author}".parameterize
  end

  def create_adventure
    Adventure.create :resource => self
  end

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
          book.detail_page_url = amazon_book[0].raw.ItemAttributes.DetailPageURL
          book.ean = amazon_book[0].raw.ItemAttributes.EAN
          #book.edition = amazon_book[0].raw.ItemAttributes.Edition
          book.isbn = amazon_book[0].raw.ItemAttributes.ISBN
          book.number_of_pages= amazon_book[0].raw.ItemAttributes.NumberOfPages
          book.product_group = amazon_book[0].raw.ItemAttributes.ProductGroup
          book.studio = amazon_book[0].raw.ItemAttributes.Studio
          book.publisher = amazon_book[0].raw.ItemAttributes.Publisher
          book.publication_date = amazon_book[0].raw.ItemAttributes.PublicationDate
          book.medium_image = amazon_book[0].raw.ImageSets.ImageSet.MediumImage.URL
          book.medium_tiny = amazon_book[0].raw.ImageSets.ImageSet.TinyImage.URL
          book.thumbnail_image = amazon_book[0].raw.ImageSets.ImageSet.ThumbnailImage.URL
        end
      end
      book = super(*args)
    end
    book
  end

end
