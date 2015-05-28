# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def error_messages_in_gr_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      content_tag("div",
        content_tag(
          options[:header_tag] || "h2",
          "#{I18n.t "helpers.could_not_register_details"}!"
        ) +
        content_tag("p", "#{I18n.t "helpers.following_problems"}:") +
        content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
        "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
      )
    else
      ""
    end
  end
  
  def page_title
    title = Hash.new
    title["register"] = "#{I18n.t "helpers.titles.register"}"
    title["cert"] = "#{I18n.t "helpers.titles.cert"}"
    title["support"] = "#{I18n.t "helpers.titles.support"}"
    title["account"] = "#{I18n.t "helpers.titles.account"}"
    title["host"] = "#{I18n.t "helpers.titles.host"}"
    title["ra"] = "#{I18n.t "helpers.titles.ra"}"
    title["ca"] = "#{I18n.t "helpers.titles.ca"}"
    title["myproxy"] = "#{I18n.t "helpers.titles.myproxy"}"
    
    @page_title || title[params[:controller]]
  end
  
  def webapp_path
    result = page_title || ""
    if params[:action] && params[:action] != "index" && params[:controller] != "site"
      result = result + " > " + (@action_title || params[:action])
    end
    result
  end
end
