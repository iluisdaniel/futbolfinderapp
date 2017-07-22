class GamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create]

	def index
		@user = current_user
		@business = current_business
		if @business != nil
			@games = Game.where(business_id: @business).order(created_at: :desc)
		elsif @user !=nil
			@games = Game.where(user_id: @user).order(created_at: :desc)
		end
	end

	def show
		@game = Game.find(params[:id])

		if logged_in? 
			@business = current_business
		
			if !(@business.id == @game.business_id)
				@game = nil
				redirect_to games_path
			end
		end

		if signed_in?
				@user = current_user

				if !(@user.id == @game.user_id)
					@game = nil
					redirect_to games_path
				end
		end		
	end

	def new
		@game = Game.new
	end

	def create
		@game = Game.new(game_params)


		if logged_in?
			@b = current_business
			@game[:business_id] = @b.id 
		end

		# available_field = assign_field_id(@game[:number_players], @game[:business_id], @game[:date], @game[:time])
		# if !(available_field = nil)
		# 	@game[:field_id] = available_field
		# else
		# 	flash[:warning] = "hey" + available_field.to_s
		# end

		if @game.save
			redirect_to games_path
			flash[:success] = "Game was created"
		else
			render 'new'
		end
	end

	private

	def game_params
		params.require(:game).permit(:date, :time, :user_id, :business_id, :field_id, :end_time)
	end

	# def assign_field_id(number_players, business_id, date, time)
	# 	fields = Field.where(business_id: business_id, number_players: number_players)
	# 	games = Game.where(date: date, time: time, number_players: number_players)

	# 	field_ids_in_games = Array.new

	# 	#check if there are fields availble at that time
	# 	if games.count >= fields.count
 #          return nil
 #        end

          
 #        games.each do |g|
 #        	field_ids_in_games.push(g.field_id)
 #        end
	    

	# 	fields.each do |f|			
	# 		if !(field_ids_in_games.include?(f.id))
	# 			return f.id
	# 		end
	# 	end

	# 	return nil
	# end
end
