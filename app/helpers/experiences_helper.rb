module ExperiencesHelper

  def confirm_message
    case @experience.code
      when 0
        'In your read bookcase'
      when 1
        'In your reading bookcase'
      when 2
        'In your next bookcase'
      when 3
        'Recommended'
    end

  end

end
