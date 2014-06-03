# require 'pry'

def initial_cards(num_decks)
  cards = ['A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K'].product(['clubs', 'spades','hearts','diamonds']) * num_decks
end

# If dealer is true, the second card of dealers' will be hidden to player at first round.
# By default we set dealer to false so that player can see every card.
def show_cards(person_cards, dealer = false)

  person_cards.length.times do
    print " ----- "
  end
  puts

  person_cards.each do |card|
    if !dealer || card == person_cards[0]
      if card[0].to_s.length == 2 
        print "| #{card[0]}  |" 
      else
        print "| #{card[0]}   |"    
      end
    elsif dealer && card == person_cards[1]
      print "|     |" 
    end
  end
  puts
  person_cards.each do |card|
    # binding.pry
    if !dealer || card == person_cards[0]
      suit = case card[1]
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
    elsif dealer && card == person_cards[1]
      print "|     |"
    end
      
  end
  puts

  person_cards.length.times do
  print " ----- "
  end
  puts
end

def show_message(message)
  puts
  p "=>#{message}"
  puts
end

def show_on_table(dealer_cards,player_cards, dealer_name, player_name, dealer)
  show_message("#{dealer_name}'s cards")
  show_cards(dealer_cards, dealer)
  show_message("#{player_name}'s cards")
  show_cards(player_cards)
end

# RULES is temporarily left blank to save some space.
def greeting_rules
  show_message("Welcome to BlackJack, I am your dealer today, Jack Black. May I know your name?")
  dealer_name = "Jack Black"
  player_name = gets.chomp
  show_message("Hello #{player_name}, would you like to learn rules first?(y/n)")
  while true
    case gets.chomp.downcase
    when 'y'
      show_message("RULES")
      show_message("Ready to begin?(y/n)")
      while true
        case gets.chomp.downcase
        when 'y'
          break
        when 'n'    
          show_message("Ready to begin?") 
        end   
      end
      break
    when 'n'
      show_message("Okay, let's start the game.")
      break
    else
      show_message("Sorry? Would you like to learn rules first?(y/n)")
    end
  end
  return player_name, dealer_name
end

def calculate_value(cards, max = 21)
  value = 0
    cards.each do |card|
      value += case card[0]
               when 'A'
                 11
               when 'J' 
                 10
               when 'Q'
                 10
               when 'K'
                 10
               else
                 card[0]
               end
              end
  if value > max
    # binding.pry
# If value is bigger than max, go to check if it is soft or hard.
# cards contain Ace might be soft, re-calculate value against max.
    ace_cards = cards.select{|card| card[0] == 'A'}
    if ace_cards.empty?
      return value
    else
      until ace_cards.empty?
      ace_cards.pop
      # binding.pry
      value -= 10
      # binding.pry
      return value if value <= max
      end
    end
  end
  return value
end

def deliver_cards(person_cards, cards)
  person_cards.push(cards.pop)
end

def bust?(person_cards, bj_max = 21)
  (calculate_value(person_cards) <= bj_max)? false : true
end

# Dealer needs to decide if or not to get the next cards, always to see whether value on hand bigger than 17.
def dealer_hits?(dealer_cards, dealer_max = 17)
  (calculate_value(dealer_cards) < dealer_max)? true : false 
end

def player_hits_bust?(player_cards,cards)
  deliver_cards(player_cards,cards)
  # binding.pry
  bust?(player_cards)? true : false
end

def player_stands(dealer_cards,cards)
  while true
    if dealer_hits?(dealer_cards, 17)
      deliver_cards(dealer_cards,cards)
    else
      break
    end
  end
end

def who_is_winner?(player_cards,dealer_cards)
  # binding.pry
  if bust?(player_cards)
    return dealer_cards, player_cards, "dealer"
  elsif bust?(dealer_cards)
    return player_cards, dealer_cards, "player"
  elsif calculate_value(player_cards) >= calculate_value(dealer_cards)
    return player_cards, dealer_cards, "player"
  elsif calculate_value(player_cards) < calculate_value(dealer_cards)
    return dealer_cards, player_cards, "dealer"
  end
end
 

def game_start(dealer_name, player_name)

  cards = initial_cards(1)
  puts "shuffling cards......"
  cards.shuffle!
  sleep 1

  dealer_cards = []
  player_cards = []

  puts "delivering cards......"
  sleep 1
  2.times do 
    deliver_cards(player_cards,cards)
    deliver_cards(dealer_cards,cards)
  end

  while true
    show_on_table(dealer_cards, player_cards, dealer_name, player_name, true)

    show_message("would you like to hit or stand?(hit/stand)")

    case gets.chomp.downcase
    when 'hit'
      break if player_hits_bust?(player_cards,cards)
    when 'stand'
      player_stands(dealer_cards,cards)
      break
    else
      show_message("sorry? input 'hit' to hit 'stand' to stand")
    end
  end
  winner_cards, loser_cards, winner = who_is_winner?(player_cards,dealer_cards)
  
  if winner == 'dealer'
    show_on_table(dealer_cards,player_cards, dealer_name, player_name, false)
    show_message("Oh sorry #{player_name}, you may try once again..")
  else
    show_on_table(dealer_cards,player_cards, dealer_name, player_name, false)   
    show_message("Congrats, #{player_name}, you are the winner.")
  end
end



# Game started~
player_name, dealer_name = greeting_rules
game_start(dealer_name, player_name)
while true
  show_message("Would you like to play again?(y/n)")
  case gets.chomp.downcase
  when 'y'
    game_start(dealer_name, player_name)
  when 'n'
    break
  else
    show_message("Sorry? I didn't catch it.")
  end       
end


