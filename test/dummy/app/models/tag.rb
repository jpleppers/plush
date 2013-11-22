class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy

  def to_label
    "#{name}, #{color}"
  end
end