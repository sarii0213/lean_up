namespace :oneshot do
  desc '既存のobjectivesのorderの値を入れる'
  task set_orders_for_objectives: :environment do
    User.find_each do |user|
      user.objectives.order(:updated_at).each.with_index do |objective, index|
        objective.update!(order: index)
      end
    end
  end
end
