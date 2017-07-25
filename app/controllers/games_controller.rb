class GamesController < ApplicationController
	before_action :signed_in_business_or_user?, only: [:index, :show, :new, :create, :destroy]
	before_action :correct_business,   only: :destroy
	before_action :correct_user,   only: :destroy

	def index
		@user = current_user
		if logged_in?
			@games = current_business.games.order(created_at: :desc)
			#@games = Game.where(business_id: @business).order(created_at: :desc)
		elsif signed_in?
			@games = current_user.games.order(created_at: :desc)
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
		if logged_in?
			@game = current_business.games.build(game_params)
			@b = current_business
			@game[:business_id] = @b.id 
		end

		if signed_in?
			@game = current_user.games.build(game_params)
			@u = current_user
			@game[:user_id] = @u.id
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

	def destroy
		@game.destroy
		redirect_to root_path
	end

	private

	def game_params
		params.require(:game).permit(:date, :time, :user_id, :business_id, :field_id, :end_time)
	end

	def correct_business
	      @game = current_business.games.find_by(id: params[:id])
	      redirect_to root_url if @game.nil?
    end

    def correct_user
	      @game = current_user.games.find_by(id: params[:id])
	      redirect_to root_url if @game.nil?
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
