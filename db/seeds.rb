# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

  read_books = []
  current_books = []
  
  # Stephen king it
  read_books << Book.find_by_asin('0451169514')

  # Iboga
  read_books << Book.find_by_asin('1594771766')

  # Stephen king Salem's Lot
  current_books << Book.find_by_asin('0671039741')

  # Steven Levit Freakonomics 
  read_books << Book.find_by_asin('0060731338')

  # Bram Stoker Drakula 
  current_books <<  Book.find_by_asin('0486411095')

  #David Heinemeer Agile Web Development with Ruby on Rails
  current_books << Book.find_by_asin('0486411095')

  user = User.create(:username => 'ritalacantaora',:first_name => 'rita',:last_name => 'lacantaora')

  read_books.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = user.id
      end
  end 
  current_books.each do |book|
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = user.id
        experience.started_at = Time.now
      end
  end 
