module BooksHelper


  def by_authors(authors)
    if authors.class.eql? Array
      result = authors[0..(authors.size - 2)].join(', ')
      result << " and #{authors.last}"
    else 
      result = authors
    end
    result 
      

  end

  def title(type)
    case type
      when 0
        'Your bookshelf - Books that you have read'
      when 1
        'Books that you are reading'
      when 2
        'Your next books.'
      when 3
        'Recommendations'
    end
  end

  def bookcase_path(type)
    case type
      when 0
        read_books_path(:id => @user.id)
      when 1
        reading_books_path(:id => @user.id)

      when 2
        next_books_path(:id => @user.id)

      when 3
        recommended_books_path(:id => @user.id)

    end

  end

end
