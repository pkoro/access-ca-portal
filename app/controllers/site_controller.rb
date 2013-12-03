class SiteController < ApplicationController
  def show
    if params[:id].nil?
      params[:id] = "home"
    end
    if params[:id].class.to_s == "String"
     render_comatose :page=>params[:id], :layout => true
     #render 'register/index.rhtml'
    elsif params[:id].class.to_s == "Array"
      if I18n.available_locales.collect {|locale| locale.to_s}.member?(params[:id][0])
        I18n.locale = params[:id][0]
        params[:id].delete_at(0)
      end
     render_comatose :page=>params[:id].join("/"), :layout => true
     #render 'register/index.rhtml'
    else
      render :text=>"Failed?" + params[:id].class.to_s
    end
  end
end
