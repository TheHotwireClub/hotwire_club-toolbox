module ApplicationHelper
  def favorite_button_icon(favorite)
    favorite ? "★" : "☆"
  end
end
