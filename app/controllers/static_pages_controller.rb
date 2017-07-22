class StaticPagesController < ApplicationController
  
  def home
  	@user = current_user
	@business = current_business

	week = 7.days.from_now.beginning_of_day

	if @business != nil
		@games = Game.where(business_id: @business, :date => Date.today.beginning_of_day..week ).order(date: :asc)
	elsif @user !=nil
		@games = Game.where(user_id: @user, :date => Date.today.beginning_of_day..week).order(date: :desc)
	end

  end

  def help
  end

  def about
  end
end
