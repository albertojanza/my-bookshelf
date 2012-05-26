module ApplicationHelper

  def loading_image
    escape_javascript image_tag('spinner.gif') 
  end

  def url_for(options = nil)
    if Hash === options
      if options[:like]
        options[:protocol] = 'http' 
        options.delete :like
      else
        options[:canvas] = true if params[:action].eql?('canvas') || params[:canvas]
      end
    end
    super(options)
  end


end
