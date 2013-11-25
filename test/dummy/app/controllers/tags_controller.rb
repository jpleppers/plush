class TagsController < ApplicationController

  def index
    render json: Tag.limit(10).offset(30).map{|t| {value: t.id, label: t.to_label}}
  end

  def search
    render json: Tag.where('name ILIKE ?', "%#{params[:query]}%").to_a.map{|t| {value: t.id, name: t.name.gsub(/(.)([A-Z])/,'\1 \2'), color: t.color, label: t.to_label}}.to_json
  end



end