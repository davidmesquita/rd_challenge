# spec/routing/carts_routing_spec.rb
require "rails_helper"

RSpec.describe CartsController, type: :routing do
  it "routes POST /cart to carts#add_new_item" do
    expect(post: "/cart").to route_to("carts#add_new_item")
  end

  it "routes POST /cart/add_item to carts#update_item_quantity" do
    expect(post: "/cart/add_item").to route_to("carts#update_item_quantity")
  end

  it "routes DELETE /cart/:product_id to carts#remove_item" do
    expect(delete: "/cart/1").to route_to("carts#remove_item", product_id: "1")
  end

  it "routes DELETE /cart/:product_id/remove_all to carts#remove_all" do
    expect(delete: "/cart/1/remove_all").to route_to("carts#remove_all", product_id: "1")
  end

  it "routes GET /cart to carts#show" do
    expect(get: "/cart").to route_to("carts#show")
  end
end
