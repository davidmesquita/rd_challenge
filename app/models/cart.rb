class Cart < ApplicationRecord
  enum status: { active: 0, abandoned: 1, purchased: 2 }

  def add_product(product_id, quantity)
    items[product_id.to_s] = (items[product_id.to_s] || 0) + quantity.to_i
    save!
  end

  def remove_product(product_id)
    items.delete(product_id.to_s)
    save!
  end

  def products_payload
    Product.where(id: items.keys).map do |product|
      qty = items[product.id.to_s]
      {
        id: product.id,
        name: product.name,
        quantity: qty,
        unit_price: product.price,
        total_price: (product.price * qty)
      }
    end
  end

  def total_price
    products_payload.sum { |p| p[:total_price] }
  end
end
