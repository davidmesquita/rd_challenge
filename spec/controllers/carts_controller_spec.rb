require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let!(:product) { Product.create(name: "Produto Teste", price: 10.0) }

  describe 'POST #add_new_item' do
    it 'adiciona um produto ao carrinho' do
      post :add_new_item, params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['products'].size).to eq(1)
      expect(json['products'].first['id']).to eq(product.id)
      expect(json['products'].first['quantity']).to eq(2)
      expect(session[:cart][product.id.to_s]).to eq(2)
    end
  end

  describe 'PATCH #update_item_quantity' do
    before { session[:cart] = { product.id.to_s => 2 } }

    it 'atualiza a quantidade de um produto existente' do
      patch :update_item_quantity, params: { product_id: product.id, quantity: 3 }

      expect(response).to have_http_status(:ok)
      expect(session[:cart][product.id.to_s]).to eq(5)
      json = JSON.parse(response.body)
      expect(json['products'].first['quantity']).to eq(5)
    end

    it 'remove o produto se quantidade ficar zero ou negativa' do
      patch :update_item_quantity, params: { product_id: product.id, quantity: -2 }

      expect(session[:cart]).not_to have_key(product.id.to_s)
      json = JSON.parse(response.body)
      expect(json['products']).to be_empty
    end
  end

  describe 'DELETE #remove_item' do
    context 'quando o produto está no carrinho' do
      before { session[:cart] = { product.id.to_s => 2 } }

      it 'diminui a quantidade em 1' do
        delete :remove_item, params: { product_id: product.id }

        expect(session[:cart][product.id.to_s]).to eq(1)
        json = JSON.parse(response.body)
        expect(json['products'].first['quantity']).to eq(1)
      end

      it 'remove o produto se a quantidade chegar a zero' do
        session[:cart][product.id.to_s] = 1
        delete :remove_item, params: { product_id: product.id }

        expect(session[:cart]).not_to have_key(product.id.to_s)
        json = JSON.parse(response.body)
        expect(json['products']).to be_empty
      end
    end

    context 'quando o produto não está no carrinho' do
      it 'retorna not_found' do
        delete :remove_item, params: { product_id: product.id }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Produto não encontrado no carrinho')
      end
    end
  end

  describe 'DELETE #remove_all' do
    context 'quando o produto está no carrinho' do
      before { session[:cart] = { product.id.to_s => 5 } }

      it 'remove o produto completamente' do
        delete :remove_all, params: { product_id: product.id }

        expect(session[:cart]).not_to have_key(product.id.to_s)
        json = JSON.parse(response.body)
        expect(json['products']).to be_empty
      end
    end

    context 'quando o produto não está no carrinho' do
      it 'retorna not_found' do
        delete :remove_all, params: { product_id: product.id }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Produto não encontrado no carrinho')
      end
    end
  end

  describe 'GET #show' do
    it 'retorna o carrinho vazio se não houver produtos' do
      get :show

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products']).to be_empty
      expect(json['total_price']).to eq(0.0)
    end

    it 'retorna os produtos do carrinho' do
      session[:cart] = { product.id.to_s => 3 }

      get :show

      json = JSON.parse(response.body)
      expect(json['products'].size).to eq(1)
      expect(json['products'].first['quantity']).to eq(3)
      expect(json['total_price'].to_f).to eq(30.0)
    end
  end
end
