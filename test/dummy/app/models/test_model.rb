class TestModel < ActiveRecord::Base
  has_many :taggings, dependent: :destroy, inverse_of: :taggings
  has_many :tags, through: :taggings

end