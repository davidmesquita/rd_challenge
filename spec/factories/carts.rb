FactoryBot.define do
  factory :cart do
    status { :active }
    total_price { 0 }
    items { {} }
    updated_at { Time.current }
  end

  factory :shopping_cart, class: 'Cart' do
    status { :active }
    total_price { 0 }
    items { {} }
    updated_at { Time.current }
  end
end
