class CartsController < ApplicationController

  def add_new_item
    product_id = params[:product_id].to_s
    quantity   = params[:quantity].to_i

    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity

    render json: cart_payload, status: :created
  end

  def update_item_quantity
    product_id = params[:product_id].to_s
    quantity   = params[:quantity].to_i

    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity
    session[:cart].delete(product_id) if session[:cart][product_id] <= 0

    render json: cart_payload
  end

  def remove_item
    product_id = params[:product_id].to_s

    unless session[:cart]&.key?(product_id)
      render json: { error: "Produto não encontrado no carrinho" }, status: :not_found
      return
    end

    session[:cart][product_id] -= 1
    session[:cart].delete(product_id) if session[:cart][product_id] <= 0

    render json: cart_payload
  end

  def remove_all
    product_id = params[:product_id].to_s

    unless session[:cart]&.key?(product_id)
      render json: { error: "Produto não encontrado no carrinho" }, status: :not_found
      return
    end

    session[:cart].delete(product_id)
    render json: cart_payload
  end

  def show
    render json: cart_payload
  end

  private

  def cart_payload
    return { id: 0, products: [], total_price: 0.0 } unless session[:cart]&.any?

    products = Product.where(id: session[:cart].keys).map do |p|
      qty = session[:cart][p.id.to_s]
      {
        id: p.id,
        name: p.name,
        quantity: qty,
        unit_price: p.price,
        total_price: p.price * qty
      }
    end

    total_price = products.sum { |p| p[:total_price] }

    { id: session[:cart_id] || 0, products: products, total_price: total_price }
  end
end
