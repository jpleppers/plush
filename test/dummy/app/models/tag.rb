class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  belongs_to :group

  def to_label
    "#{name}, #{color}"
  end

  def to_hash
    { value: id, 
      name: name.gsub(/(.)([A-Z])/,'\1 \2'), 
      color: color, 
      label: to_label
    }
  end
end