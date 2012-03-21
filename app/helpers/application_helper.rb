module ApplicationHelper

  def loading_image
    escape_javascript image_tag('spinner.gif') 
  end

  def url_for(options = nil)
    if Hash === options
      options[:canvas] = true if params[:action].eql?('canvas') || params[:canvas]
    end
    super(options)
  end


end
