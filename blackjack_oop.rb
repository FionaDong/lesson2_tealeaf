require 'pry'

module Showable

	def show_cards(cards, dealer_hand = false)
	  cards.length.times do
	    print " ----- "
	  end
	  puts

	  cards.each do |card|
	    if !dealer_hand || card == cards[0]
	      if card.value.to_s.length == 2 
	        print "| #{card.value}  |"
	      else
	        print "| #{card.value}   |"
	      end
	    elsif dealer_hand && card == cards[1]
	      print "|     |"
	    end
	  end
	  puts

	  cards.each do |card|
	    if !dealer_hand || card == cards[0]
	      suit = case card.suit
	            when "diamonds"
	              "\u2666"
	            when "hearts"
	              "\u2665"
	            when "spades"
	              "\u2660"
	            when "clubs"
	              "\u2663"
	            end
	      print "| #{suit}   |"
	    elsif dealer_hand && card == cards[1]
	      print "|     |"
	    end
	  end
	  puts

	  cards.length.times do
	  	print " ----- "
	  end
	  puts

	end
end

class Card
	attr_reader :suit, :value
	def initialize(suit, value)
		@suit = suit
		@value = value
	end
end

class Shoe
	attr_accessor :decks
	def initialize(num_decks)
		@decks = []
		['A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K'].each do |value|  
			['clubs', 'spades','hearts','diamonds'].each do |suit|
				@decks << Card.new(suit, value)
			end
		end
		self.decks *= num_decks
	end

	def scramble!
		decks.shuffle!
	end

	def deliver
		decks.pop
	end
end

class Person
	include Showable
	attr_accessor :name, :cards

	def initialize(name)
		@name = name
		@cards = []
	end

	def show(dealer_hand = false)
		puts "#{name}'s cards are:"
		show_cards(cards, dealer_hand)
		# binding.pry
		puts "#{name} got #{calculate_value}." if !dealer_hand
	end

	def calculate_value
	  v = 0
    cards.each do |card|
      v += case card.value
               when 'A'
                 11
               when 'J' 
                 10
               when 'Q'
                 10
               when 'K'
                 10
               else
                 card.value
               end
              end
	  
		# If value is bigger than max, go to check if it is soft or hard.
		# cards contain Ace might be soft, re-calculate value against max.
		cards.select{|card| card.value == 'A'}.count.times do
			v -= 10 if v > 21	
		end
	  return v
	end

	def hit_bj?
		calculate_value == 21 ? true : false
	end

	def bust?
		calculate_value > 21 ? true : false
	end

end
class Dealer < Person

	def deal(person, shoe)
		person.cards << shoe.deliver
	end

	def hit?
		calculate_value < 17 ? true : false
	end

end

class Player < Person; end

class Game
	attr_reader :shoe, :dealer, :player
	attr_accessor :winner

	def initialize(dealer_name)
		@dealer = Dealer.new(dealer_name)
		show_message("Welcome to BlackJack, I am your dealer today, Jack Black. May I know your name?")
		@player = Player.new(gets.chomp)
	end

	def start(num_decks, agian = false)
		if agian
			show_message("Welcome back, #{player.name}, Let's go~~")
			player.cards.clear
			dealer.cards.clear
		else
			show_message("Hello #{player.name}, Let's start~~")
		end
		@shoe = Shoe.new(num_decks)

		shoe.scramble!
		sleep 1
		show_message("Shuffling cards....")
		2.times do
			dealer.deal(dealer, shoe)
			dealer.deal(player, shoe)
		end
		sleep 1
 		show_message("Delivering cards......")
 		sleep 1
# binding.pry

		if player.hit_bj?
			self.winner = player
		else
			while true
				dealer.show(true)
	  		player.show

				show_message("would you like to hit or stand?(hit/stand)")

			  case gets.chomp.downcase
			  when 'hit'
			  	dealer.deal(player, shoe)
			  	
			    if player.bust?
			    	# binding.pry
			    	self.winner = dealer
			    	break
			    elsif player.hit_bj?
			    	# binding.pry
			    	self.winner = player
			    	break
			    end
			  when 'stand'
			  	if dealer.hit_bj?
			  		self.winner = dealer
			  		break
			  	end
			  	while dealer.hit?
			      dealer.deal(dealer, shoe)
			      if dealer.bust?
			      	self.winner = player
			      	break
			      elsif dealer.hit_bj?
			    		self.winner = dealer
			    		break
			    	end 
			    end
			  	break
			  else
			    show_message("sorry? input 'hit' to hit 'stand' to stand")
			  end
			end
		end
		who_is_winner
end
		
	def show_message(message)
	  puts
	  p "=>#{message}"
	  puts
	end

	def who_is_winner
		# binding.pry
		dealer.show
	  player.show
	  # binding.pry
		if !winner 
			self.winner = player.calculate_value >= dealer.calculate_value ? player : dealer
		end
		if winner == dealer
			# binding.pry
			show_message("Oh sorry #{player.name}, you may try once again..")
		elsif winner == player
			show_message("Congrats #{player.name}, you are the winner.")
		end		
	end

end

blackjack = Game.new('Jack Black')	  
blackjack.start(1)

while true	
	puts "Would you like to play again?(y/n)"
	
	case gets.chomp.downcase
  when 'y'
    blackjack.start(1, true)
  when 'n'
    puts "See you next time."
    exit
  else
    puts "Sorry? I didn't catch it." 
  end       
end	


# dealer = Dealer.new('Jack Black')

# dealer.cards.push(Card.new('hearts',4))
# dealer.cards.push(Card.new('hearts',6))

# puts dealer.calculate_value
