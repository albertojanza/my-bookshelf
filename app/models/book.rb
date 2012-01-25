class Book < ActiveRecord::Base
  has_one :adventure, :as => :resource

  after_create :create_adventure


  def create_adventure
    Adventure.create :resource => self
  end

  #
  def self.find_by_asin(*args) 
    book = super(*args)
    if book.nil?
      puts args[0]

      client = ASIN::Client.instance
      amazon_book = client.lookup args[0]
      unless amazon_book.empty?
        Book.create(:asin =>  args[0],:author => amazon_book[0].raw.ItemAttributes.Author, :title => amazon_book[0].raw.ItemAttributes.title)
      end
      book = super(*args)
    end
    book
  end

end
