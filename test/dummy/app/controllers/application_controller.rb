class ApplicationController < ActionController::Base
  helper Plush::Engine.helpers
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
