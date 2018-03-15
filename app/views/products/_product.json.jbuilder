json.extract! product, :id, :name, :price, :brand, :category_id, :description, :quantity, :rating, :created_at, :updated_at
json.url product_url(product, format: :json)
