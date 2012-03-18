module BooksHelper


  def by_authors(authors)
    if authors.class.eql? Array
      result = authors[0..(authors.size - 2)].join(', ')
      result << " #{I18n.t('and')} #{authors.last}"
    else 
      result = authors
    end
    result 
      

  end


  def empty_legend(type)
    if logged_in? && @user.eql?(current_user)
      case type
        when 0
          I18n.t('my_empty_read_bookshelf_html') 
        when 1
          I18n.t('my_empty_reading_bookshelf_html')
        when 2
          I18n.t('my_empty_next_bookshelf_html')
        when 3
          I18n.t('my_empty_recommended_bookshelf_html')
      end
    else
      case type
        when 0
          I18n.t('his_empty_read_bookshelf_html', :name => @user.name.capitalize) 
        when 1
          I18n.t('his_empty_reading_bookshelf_html', :name => @user.name.capitalize)
        when 2
          I18n.t('his_empty_next_bookshelf_html', :name => @user.name.capitalize) 
        when 3
          I18n.t('his_empty_recommended_bookshelf_html', :name => @user.name.capitalize)
      end

    end
  end


  def title(type)
    if logged_in? && @user.eql?(current_user)
      case type
        when 0
          I18n.t('my_read_bookshelf') 
        when 1
          I18n.t('my_reading_bookshelf')
        when 2
          I18n.t('my_next_bookshelf')
        when 3
          I18n.t('my_recommended_bookshelf')
      end
    else
      case type
        when 0
          I18n.t('his_read_bookshelf', :name => @user.name.capitalize) 
        when 1
          I18n.t('his_reading_bookshelf', :name => @user.name.capitalize)
        when 2
          I18n.t('his_next_bookshelf', :name => @user.name.capitalize) 
        when 3
          I18n.t('his_recommended_bookshelf', :name => @user.name.capitalize)
      end

    end
  end

  # TODO remove me
  def bookcase_path_old(type)
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
