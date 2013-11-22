class PagesController < ApplicationController

  def show
    @tags = Tag.all
  end
  
end