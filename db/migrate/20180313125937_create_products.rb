class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.string :brand
      t.integer :category_id
      t.text :description
      t.integer :quantity
      t.integer :rating

      t.timestamps
    end
  end
end
