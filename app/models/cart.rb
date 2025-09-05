class Cart < ApplicationRecord
  enum status: { active: 0, abandoned: 1, purchased: 2 }

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  attr_accessor :items

  after_initialize do
    self.items ||= {}
  end

  def add_product(product_id, quantity)
    self.items[product_id.to_s] = (items[product_id.to_s] || 0) + quantity.to_i
    save!
  end

  def update_product_quantity(product_id, quantity)
    self.items ||= {}
    self.items[product_id.to_s] ||= 0
    self.items[product_id.to_s] += quantity.to_i
    self.items.delete(product_id.to_s) if self.items[product_id.to_s] <= 0
    save!
  end

  def remove_product(product_id)
    self.items.delete(product_id.to_s)
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
        total_price: product.price * qty
      }
    end
  end

  def total_price
    products_payload.sum { |p| p[:total_price] }
  end

  def mark_as_abandoned
    update!(status: :abandoned) if updated_at <= 2.minutes.ago && active?
  end

  def remove_if_abandoned
    destroy if abandoned? && updated_at <= 7.days.ago
  end
end
