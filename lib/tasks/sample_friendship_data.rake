namespace :db do
  desc "Fill database with sample data"
  task friendpopulate: :environment do

   i = 50
   num = 98

   while i < num  do
       user_id = 1
       friend_id = i
       Friendship.create!(user_id: user_id, friend_id: friend_id, accepted: true)
       i = i +  1
   end

  end
end



