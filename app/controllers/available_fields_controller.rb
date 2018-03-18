class AvailableFieldsController < ApplicationController
	before_action :is_not_a_business?, only: :index

	@@game = nil

	def index
		#flash[:warning] = "var @@game " + @@game.to_s 
		@message = ""

		if params[:date] && !params[:date].empty?
			# for debugging
			# flash[:info] = params[:date] + "  " + params[:time]
			#TODO: change variable name to something else. the hash has businesses and field.
			@businesses = get_available_businesses(Business.get_open_businesses_at(params[:date], Time.zone.parse(params[:time])),
				params[:date], Time.zone.parse(params[:time]))

			if @businesses.empty?
				@message = "We couldn't find a business available that date."
			end
		else
			# flash[:info] = "params date empty"
			@@game = nil
		end

		

		if params[:game]
			@@game = params[:game]	
		end

		#flash[:info] = "var @@game " + @@game.to_s 
		#flash[:info] = "Date params: " + params[:date].to_s + "  Time: " + params[:time].to_s
	end

	private 

	def get_available_businesses(biz, date, time)
		bs = Hash.new
		biz.each do |b|
			b.fields.each do |f|
				t = time + 1.hour
				res = Reservation.new(date: date, time: time, end_time: t, business_id: b.id,
					field_id: f.id)
				if res.valid?
					# for debuggin
					# flash[:info] = "found a res valid"
					bs[b.name] = Array.new
					bs[b.name] << b
					bs[b.name] << f
					bs[b.name] << @@game
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

end
