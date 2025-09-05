class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.where("updated_at <= ?", 3.hours.ago)
        .where.not(status: Cart.statuses[:abandoned])
        .find_each do |cart|
      cart.update!(status: :abandoned)
    end
  end

  def remove_old_abandoned_carts
    Cart.where(status: Cart.statuses[:abandoned])
        .where("updated_at <= ?", 7.days.ago)
        .find_each(&:destroy)
  end
end
