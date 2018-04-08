class AvailableFieldsController < ApplicationController
	before_action :is_not_a_business?, only: :index
	# before_action :clear_session_variables, only: :index

	def index
		#flash[:warning] = "var @@game " + @@game.to_s 
		@message = ""
		@custom_venue = CustomVenue.new

		if  params[:date] && !params[:date].empty? && !params[:duration].empty?
			
			# for debugging
			# flash[:info] = params[:date] + "  " + params[:time]
			#TODO: change variable name to something else. the hash has businesses and field.
			if !params[:time]
				time = params[:hour] + ":" + params[:minute] + " " + params[:ampm]
			else
				time = params[:time]
			end
			@businesses = get_available_businesses(Business.get_open_businesses_at(params[:date], Time.zone.parse(time)), 
				time)

			if @businesses.empty?
				@message = "We couldn't find a business available at " + '"' + params[:date] + ", " + time + '"'
			end
		else
			if params[:game] && (params[:date].nil?)
			else
				flash[:danger] = "Please date, time, and duration are required. "
			end
			# flash[:info] = "params date empty"
			# session[:from_game] = nil
		end

	
		# if params[:game]
		# 	session[:from_game] = params[:game]	
		# end

		#flash[:info] = "var @@game " + @@game.to_s 
		#flash[:info] = "Date params: " + params[:date].to_s + "  Time: " + params[:time].to_s
	end

	private 

	def get_available_businesses(businesses, time)
		bs = Hash.new
		businesses.each do |b|
			b.fields.each do |f|
				end_time = Time.zone.parse(time) + (params[:duration].to_f).hour 
				res = Reservation.new(date: params[:date], time: Time.zone.parse(time), 
					end_time: end_time, business_id: b.id, field_id: f.id)
				if res.valid?
					# for debuggin
					# flash[:info] = "found a res valid"
					bs[b.name] = Array.new
					bs[b.name] << b
					bs[b.name] << f
					bs[b.name] << params[:game]
					bs[b.name] << params[:duration]
					bs[b.name] << time
				else
					# FOr debugging
					# res.valid?
					# flash[:warning] = res.errors.full_messages
				end
			end
		end
		return bs
	end

	def is_not_a_business?
		if logged_in?
			return false
		end
		return true
	end

	# def clear_session_variables
	# 	if !session[:res_business_id].nil?
	# 			session[:res_business_id] = nil
	# 			session[:res_field_id] = nil
	# 			session[:res_date] = nil
	# 			session[:res_time] = nil
	# 			session[:res_end_time] = nil
	# 	end
	# end

end
