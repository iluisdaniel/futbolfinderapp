namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

    99.times do |n|
        first_name  = Faker::Name.first_name
        last_name  = Faker::Name.last_name
        location = "Miami"
        slug = first_name + last_name + n.to_s
        gender = "M"
        dob = Date.today
        email = "example-#{n+1}@example.com"
        password  = "123456"
        User.create!(first_name: first_name,
                     last_name: last_name, 
                     email: email,
                     location: location,
                     slug: slug,
                     gender: gender,
                     dob: dob,
                     password: password,
                     password_confirmation: password)
    end
  end
end

