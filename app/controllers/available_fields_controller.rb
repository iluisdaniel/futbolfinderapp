class AvailableFieldsController < ApplicationController
	before_action :signed_in_user_but_not_business?, only: :index

	def index
		if params[:date]
			@businesses = get_available_businesses(Business.get_open_businesses_at(params[:date], params[:time]),
				params[:date], params[:time])
		end

		@game = Game.new
	end

	private 

	def get_available_businesses(biz, date, time)
		bs = Hash.new
		biz.each do |b|
			b.fields.each do |f|
				t = time.to_time + 1.hour
				res = Reservation.new(date: date, time: time, end_time: t.to_s, business_id: b.id,
					field_id: f.id)
				if res.valid?
					bs[b.name] = Array.new
					bs[b.name] << b
					bs[b.name] << f
				end
			end
		end
		return bs
	end

end
