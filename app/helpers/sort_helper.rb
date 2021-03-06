# Helpers to sort tables using clickable column headers.
#
# Author:  Stuart Rackham <srackham@methods.co.nz>, March 2005.
# Author:  Jonathan Conway <jonathan@agileevolved.com>, modified to allow sorting of associations, Feb 2006
# Author:  Mike Cavaliere, fixed a bug in which column names were being compared but not their
#          association which was causing problems when two tables with the same column name were
#          being sorted.
# License: This source code is released under the MIT license.
#
# - Consecutive clicks toggle the column's sort order.
# - Sort state is maintained by a session hash entry.
# - Icon image identifies sort column and state.
# - Typically used in conjunction with the Pagination module.
#
# Example code snippets:
#
# Controller:
#
#   helper :sort
#   include SortHelper
# 
#   def list
#     sort_init 'last_name'
#     sort_update
#     @items = Contact.find_all nil, sort_clause
#   end
# 
# Controller (using Pagination module):
#
#   helper :sort
#   include SortHelper
# 
#   def list
#     sort_init 'last_name'
#     sort_update
#     @contact_pages, @items = paginate :contacts,
#       :order_by => sort_clause,
#       :per_page => 10
#   end
# 
# View (table header in list.rhtml):
# 
#   <thead>
#     <tr>
#       <%= sort_header_tag('id', :title => 'Sort by contact ID') %>
#       <%= sort_header_tag('last_name', :caption => 'Name') %>
#       <%= sort_header_tag('phone') %>
#       <%= sort_header_tag('address', :width => 200) %>
#     </tr>
#   </thead>
#
# - The ascending and descending sort icon images are sort_asc.png and
#   sort_desc.png and reside in the application's images directory.
# - Introduces instance variables: @sort_name, @sort_default.
# - Introduces params :sort_key and :sort_order.
#
module SortHelper

  # Initializes the default sort column (default_key) and sort order
  # (default_order).
  #
  # - default_key is a column attribute name.
  # - default_order is 'asc' or 'desc'.
  # - name is the name of the session hash entry that stores the sort state,
  #   defaults to '<controller_name>_sort'.
  #
  def sort_init(default_key, default_order='asc',name =nil, default_tablename = nil, is_associated = false)
    @sort_name = name || params[:controller] + '_' + params[:action] + '_sort'
    @sort_default = {:key => default_key, :order => default_order, :association => default_tablename}
    @is_associated = is_associated
  end

  # Updates the sort state. Call this in the controller prior to calling
  # sort_clause.
  #
  def sort_update()
    if params[:sort_key]
      sort = {:key => params[:sort_key], :order => params[:sort_order], :association => params[:association]}
    elsif session[@sort_name]
      sort = session[@sort_name]   
    else
      sort = @sort_default    
    end
    session[@sort_name] = sort
  end

  # Returns an SQL sort clause corresponding to the current sort state.
  # Use this to sort the controller's table items collection.
  #
  def sort_clause()
    if @is_associated
      check_association_not_null
       %{#{session[@sort_name][:association]}.#{session[@sort_name][:key]} #{session[@sort_name][:order]}}
    else
       %{#{session[@sort_name][:key]} #{session[@sort_name][:order]}}
    end
  end

  # Returns a link which sorts by the named column.
  #
  # - column is the name of an attribute in the sorted record collection.
  # - The optional caption explicitly specifies the displayed link text.
  # - A sort icon image is positioned to the right of the sort link.
  #
  def sort_link(column, caption = nil, association = nil)
    key, order, ses_association = session[@sort_name][:key], session[@sort_name][:order], session[@sort_name][:association]
    if key == column && association == ses_association
      if order.downcase == 'asc'
        icon = 'sort_asc.png'
        order = 'desc'
      else
        icon = 'sort_desc.png'
        order = 'asc'
      end
    else
      icon = nil
      order = 'asc'
    end
    caption = titleize(Inflector::humanize(column)) unless caption
    params = {:params => {:sort_key => column, :sort_order => order, :association => association}}
    link_to(caption, params) + (icon ? nbsp(2) + image_tag(icon) : '')
  end

  # Returns a table header <th> tag with a sort link for the named column
  # attribute.
  #
  # Options:
  #   :caption     The displayed link name (defaults to titleized column name).
  #   :title       The tag's 'title' attribute (defaults to 'Sort by :caption').
  #
  # Other options hash entries generate additional table header tag attributes.
  #
  # Example:
  #
  #   <%= sort_header_tag('id', :title => 'Sort by contact ID', :width => 40) %>
  #
  # Renders:
  #
  #   <th title="Sort by contact ID" width="40">
  #     <a href="/contact/list?sort_order=desc&amp;sort_key=id">Id</a>
  #     &nbsp;&nbsp;<img alt="Sort_asc" src="/images/sort_asc.png" />
  #   </th>
  #
  def sort_header_tag(column, options = {})
    association = nil    
    if options[:association]
      association = options[:association]
      options.delete(:association)
    end 
    if options[:caption]
      caption = options[:caption]
      options.delete(:caption)
    else
      caption = titleize(Inflector::humanize(column))
    end
    options[:title]= "Sort by #{caption}" unless options[:title]
    content_tag('th', sort_link(column, caption, association), options)
  end

  private

    # Return n non-breaking spaces.
    def nbsp(n)
      '&nbsp;' * n
    end

    # Return capitalized title.
    def titleize(title)
      title.split.map {|w| w.capitalize }.join(' ')
    end
    
    def check_association_not_null
      session[@sort_name][:association] = session[@sort_name][:association] ? session[@sort_name][:association] : @sort_default[:association]
    end

end