# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def error_messages_in_gr_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    if object && !object.errors.empty?
      content_tag("div",
        content_tag(
          options[:header_tag] || "h2",
          "Δεν ήταν δυνατόν να καταχωρηθούν τα στοιχεία σας!"
        ) +
        content_tag("p", "Τα ακόλουθα προβλήματα απέτρεψαν την ολοκλήρωση της διαδικασίας:") +
        content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
        "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
      )
    else
      ""
    end
  end
  
  def page_title
    title = Hash.new
    title["register"] = "Εγγραφή νέων χρηστών"
    title["cert"] = "Ψηφιακά Πιστοποιητικά"
    title["support"] = "Ομάδα Υποστήριξης"
    title["account"] = "Διαχείριση Προσωπικού Λογαριασμού"
    title["host"] = "Ψηφιακά πιστοποιητικά διακομιστών"
    title["ra"] = "Αρχή Ταυτοποίησης"
    title["ca"] = "Αρχή Πιστοποίησης"
    title["myproxy"] = "Υπηρεσία MyProxy"
    
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
