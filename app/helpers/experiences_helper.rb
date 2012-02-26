module ExperiencesHelper

  def confirm_message(code)
    case code
      when 0
        I18n.t 'in_your_read_bookshelf'
      when 1
        I18n.t 'in_your_reading_bookshelf'
      when 2
        I18n.t 'in_your_next_bookshelf'
      when 3
        I18n.t 'in_your_recommended_bookshelf'
    end
  end

  def big_confirm_message(code)
    case code
      when 0
        I18n.t 'in_your_read_bookshelf_big'
      when 1
        I18n.t 'in_your_reading_bookshelf_big'
      when 2
        I18n.t 'in_your_next_bookshelf_big'
      when 3
        I18n.t 'in_your_recommended_bookshelf_big'
    end
  end

end
