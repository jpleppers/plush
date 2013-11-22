class CreateDummyTables < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string  :name
      t.string  :color
    end

    create_table :test_models do |t|
      t.string  :name
    end

    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :test_model_id
    end
  end
end
