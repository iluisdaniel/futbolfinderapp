namespace :db do
  desc "Fill business database with sample data"
  task bizpopulate: :environment do

    10.times do |n|
        name  = Faker::Company.name
        email = "example-b-#{n+1}@example.com"
        phone = rand(1000000000..9999999999)
        address = Faker::Address.street_address
        city = Faker::Address.city
        state = Faker::Address.state
        country = Faker::Address.country
        zipcode = rand(10000..99999)
        slug = name + n.to_s  
        password  = "123456"

        b = Business.create!(name: name, email: email, phone: phone.to_s, address: address, 
                    city: city, state: state, country: country, 
                    zipcode: zipcode.to_s, password: password, password_confirmation: password, slug: slug)

        Schedule.create!(day: "Monday", open_time: Time.zone.parse("10:00:00"), close_time: Time.zone.parse("23:00:00"), 
            business_id: b.id)
        Field.create!(number_players: 10, name: "Cancha 1", description: "Esto es una prueba", 
            price: 100, business_id: b.id)
    end
  end
end


