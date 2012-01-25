module ApplicationHelper

  def loading_image
    escape_javascript image_tag('spinner.gif') 
  end

end
