# spec/requests/carts_spec.rb
require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:product) { Product.create!(name: "Produto Teste", price: 10.0) }

  describe "POST /cart" do
    it "adiciona um produto ao carrinho" do
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(1)
      expect(json["products"].first["id"]).to eq(product.id)
      expect(json["products"].first["quantity"]).to eq(2)
    end

    it "incrementa a quantidade se o produto já estiver no carrinho" do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(1)
      expect(json["products"].first["quantity"]).to eq(3)
    end
  end

  describe "POST /cart/add_item" do
    before { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

    it "aumenta a quantidade de um produto existente" do
      post '/cart/add_item', params: { product_id: product.id, quantity: 3 }, as: :json
      json = JSON.parse(response.body)
      expect(json["products"].first["quantity"]).to eq(5)
    end

    it "remove o produto se a quantidade ficar zero ou negativa" do
      post '/cart/add_item', params: { product_id: product.id, quantity: -2 }, as: :json
      json = JSON.parse(response.body)
      expect(json["products"]).to be_empty
    end
  end

  describe "DELETE /cart/:product_id" do
    before { post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json }

    it "diminui a quantidade em 1" do
      delete "/cart/#{product.id}", as: :json
      json = JSON.parse(response.body)
      expect(json["products"].first["quantity"]).to eq(1)
    end

    it "remove o produto se a quantidade chegar a zero" do
      delete "/cart/#{product.id}", as: :json
      delete "/cart/#{product.id}", as: :json
      json = JSON.parse(response.body)
      expect(json["products"]).to be_empty
    end

    it "retorna not_found se o produto não estiver no carrinho" do
      delete "/cart/999", as: :json
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Produto não encontrado no carrinho")
    end
  end

  describe "DELETE /cart/:product_id/remove_all" do
    before { post '/cart', params: { product_id: product.id, quantity: 5 }, as: :json }

    it "remove completamente o produto do carrinho" do
      delete "/cart/#{product.id}/remove_all", as: :json
      json = JSON.parse(response.body)
      expect(json["products"]).to be_empty
    end
  end

  describe "GET /cart" do
    it "retorna carrinho vazio se não houver produtos" do
      get '/cart', as: :json
      json = JSON.parse(response.body)
      expect(json["products"]).to be_empty
      expect(json["total_price"]).to eq(0.0)
    end

    it "retorna os produtos no carrinho" do
      post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json
      get '/cart', as: :json
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(1)
      expect(json["products"].first["quantity"]).to eq(3)
      expect(json["total_price"].to_f).to eq(30.0)
    end
  end
end
