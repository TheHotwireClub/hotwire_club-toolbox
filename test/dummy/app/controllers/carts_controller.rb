class CartsController < ApplicationController
  # PATCH /carts/update
  #
  # Adds a photo to the session cart and responds 204 No Content, leaving the
  # optimistic count in place.
  def update
    session[:cart_items] ||= []
    session[:cart_items] << params[:photo_id]
    session[:cart_items].uniq!

    head :no_content
  end
end
