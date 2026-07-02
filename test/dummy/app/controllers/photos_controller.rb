class PhotosController < ApplicationController
  def index
    @photos = Photo.order(:id)
  end

  # PATCH /photos/:id
  #
  # Success responds 204 No Content so Turbo does nothing and the optimistic
  # paint stands. The demo_failure path responds 422 so the client reconciles
  # (turbo:submit-end fires with success=false).
  def update
    @photo = Photo.find(params[:id])

    if params[:demo_failure].present?
      @photo.assign_attributes(photo_params)

      if @photo.save(context: :demo_failure)
        head :no_content
      else
        flash[:alert] = "Your changes could not be saved."
        head :unprocessable_entity
      end
    elsif @photo.update(photo_params)
      head :no_content
    else
      flash[:alert] = "Your changes could not be saved."
      head :unprocessable_entity
    end
  end

  private

  def photo_params
    params.expect(photo: [ :author, :favorite ])
  end
end
