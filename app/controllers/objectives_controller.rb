# frozen_string_literal: true

class ObjectivesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_objective, only: %i[show edit update destroy]

  def index
    @objectives = current_user.objectives.order(updated_at: :desc)
  end

  def show; end

  def new
    @objective = Objective.new(objective_type: :image)
  end

  def edit; end

  def create
    @objective = Objective.new(objective_params)
    if @objective.save
      redirect_to @objective
    else
      render 'new'
    end
  end

  def update
    if @objective.update(objective_params)
      redirect_to @objective
    else
      render 'edit'
    end
  end

  def destroy
    @objective.destroy
    redirect_to objectives_path
  end

  private

  def set_objective
    @objective = current_user.objectives.find(params[:id])
  end

  def objective_params
    params.require(:objective).permit(:objective_type, :verbal, :comment, :order,
                                      images: []).merge(user_id: current_user.id)
  end
end
