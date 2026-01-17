# frozen_string_literal: true

module TableHelper
  # Generates a sortable column header link for tables
  # Preserves existing query parameters and toggles sort direction
  #
  # @param column [String, Symbol] The column name to sort by
  # @param label [String] The display text for the column header
  # @return [String] HTML link with sort arrow indicators
  def sort_link(column, label)
    direction = (params[:sort] == column.to_s && params[:dir] != "desc") ? "desc" : "asc"
    arrow = if params[:sort] == column.to_s
              params[:dir] == "desc" ? " ↓" : " ↑"
            else
              ""
            end

    link_to "#{label}#{arrow}".html_safe,
            url_for(sort: column, dir: direction, **request.query_parameters.except(:sort, :dir)),
            class: "hover:text-gray-700"
  end
end
