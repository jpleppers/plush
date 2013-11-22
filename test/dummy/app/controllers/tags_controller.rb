class TagsController < ApplicationController

  def index
    respond_to do |format|
      format.js{ render json: Tag.limit(10).offset(30)}
    end
  end

  def search
    respond_to do |format|
      format.js{ render json: Tag.where('name ILIKE ?', "%#{params[:query]}%").to_a.map{|t| {id: t.id, name: t.name.gsub(/(.)([A-Z])/,'\1 \2'), color: t.color, label: t.to_label}}.to_json}
      # simulate loading time
      sleep 0.3 
    end
  end

end