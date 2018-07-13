# frozen_string_literal: true

class ImagesController < ApplicationController
  # Nested controller for slide images

  # Send a given sized slide image
  def show
    @slide = Slide.find(params[:slide_id])
    filename = ""
    case params[:size]
    when "preview"
      filename = @slide.preview_filename
    when "thumb"
      filename = @slide.thumb_filename
    when "transparent"
      filename = @slide.respond_to?(:transparent_filename) ? @slide.transparent_filename : @slide.full_filename
    else
      filename = @slide.full_filename
    end
    respond_to do |format|
      format.html do
        # Conditional get
        render body: nil, status: 404 if @slide.images_updated_at.nil?
        return unless stale?(last_modified: @slide.images_updated_at.utc, etag: @slide)

        # Set content headers to allow CORS
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Request-Method"] = "GET"
        if @slide.ready
          send_file filename, disposition: "inline"
        else
          render body: nil, status: 404
        end
      end
      format.js { render :show }
    end
  rescue ActiveRecord::RecordNotFound, ActionController::MissingFile
    # Slide not found, return 404
    render body: nil, status: 404
  end
end
