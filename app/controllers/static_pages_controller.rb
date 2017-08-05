class StaticPagesController < ApplicationController
  
  def home
  	@user = current_user
	@business = current_business

	week = 7.days.from_now.beginning_of_day

	if @business != nil
		@games = Game.where(business_id: @business, :date => Date.today.beginning_of_day..week ).order(date: :asc)
	elsif @user !=nil
		@games = Game.joins(game_lines: :user).where(game_lines: {user_id: current_user.id}, :date => Date.today.beginning_of_day..week).order(created_at: :desc)
	end

  end

  def help
  end

  def about
  end
end
