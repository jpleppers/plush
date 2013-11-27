class TagsController < ApplicationController

  def index
    render json: Tag.limit(10).offset(30).map{|t| {value: t.id, label: t.to_label}}
  end

  def search
    render json: Tag.where('name ILIKE ?', "%#{params[:q]}%").to_a.map{|t| t.to_hash}.to_json
  end

  def search_grouped
    tags = Tag.where('name ILIKE ?', "%#{params[:q]}%").group_by(&:group).map do |group, tags|
      { :"#{group.name}" => tags.map{|t| t.to_hash} }
    end
    render json: tags.to_json
  end


end