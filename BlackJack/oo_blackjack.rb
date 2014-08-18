require 'pry'

class String
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end

#--------------------------------------------------->>

class Participant
  include Comparable
  attr_accessor :name, :cards 
  attr_reader :gamble_history, :vs_result

  def initialize(name)
    @name = name        
    @cards = [] 
    @vs_result = {} # {competitor_name:nil} # { competitor_name: result win/lose }
    @gamble_history = [] # [ { cards:cards, vs_result:vs_result } ] 
                         
  end

  def set_vs_result (competitor_name:nil,result:nil)
    (competitor_name && result) ? (@vs_result[competitor_name] = result) : (puts "Wrong:: Both 'competitor_name' and 'result' can't be null.")    
  end

  def set_gamble_history(cards, vs_result)    
    @gamble_history << { cards:cards.dup, vs_result:vs_result.dup }        
  end

  def <=> (participant)  
    return 0 if self.is_blackjack? && participant.is_blackjack?
    return 1 if self.is_blackjack? && participant.is_twentyone?
    return 1 if self.is_blackjack? && participant.is_bursted?
    return 1 if self.is_blackjack? && (participant.calculate_cards_total < 21)

    return -1 if self.is_twentyone? && participant.is_blackjack?
    return 0 if self.is_twentyone? && participant.is_twentyone?
    return 1 if self.is_twentyone? && participant.is_bursted?
    return 1 if self.is_twentyone? && (participant.calculate_cards_total < 21)

    return -1 if self.is_bursted? && participant.is_blackjack?
    return -1 if self.is_bursted? && participant.is_twentyone?
    return 0 if self.is_bursted? && participant.is_bursted?
    return -1 if self.is_bursted? && (participant.calculate_cards_total < 21)
    
    return -1 if (self.calculate_cards_total < 21) && participant.is_blackjack?
    return -1 if (self.calculate_cards_total < 21) && participant.is_twentyone?
    return 1 if (self.calculate_cards_total < 21) && participant.is_bursted?
    if (self.calculate_cards_total < 21) && (participant.calculate_cards_total < 21)
      return 1 if (self.calculate_cards_total > participant.calculate_cards_total)
      return 0 if (self.calculate_cards_total == participant.calculate_cards_total)
      return -1 if (self.calculate_cards_total < participant.calculate_cards_total)
    end          
  end

   def is_blackjack?    
    cards.count ==2 && calculate_cards_total ==21
  end
  
  def is_twentyone?    
    cards.count > 2 && calculate_cards_total == 21
  end
  
  def is_bursted?     
     calculate_cards_total > 21
  end

  def calculate_cards_total    
    total = 0
    suit_Ace_count = 0    
    cards.each do |c|      
      number = c.card_value
      suit = c.suit    
      if number == "A"
          suit_Ace_count += 1
          total += 11
      else
          total += number
      end
    end
    suit_Ace_count.times do 
      break if total <= 21
      total -= 10
    end    
    return total
  end

  def show_cards
    @cards.map { |c| c.to_s}
  end

  def play_again
    reset_cards
  end

  private  
  def reset_cards    
    cards.clear
    vs_result.clear
  end 
end

#--------------------------------------------------->>

class Delear < Participant
  def initialize(name)
    super(name)
    @deck = Deck.new
  end

  def hit_card?        
    if is_blackjack?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Blakcjack!"
      return false
    elsif is_twentyone?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Twenty-One!"
      return false
    elsif is_bursted?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Burst!"
      return false
    elsif  calculate_cards_total >= 17 
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue} "
      return false
    else
      return true
    end    
  end

  def deal_cards(participants) 
    2.times do
      participants.each { |p| p.cards << @deck.flick_a_card }       
    end    
  end

  def participant_stay_or_hit(participants) 
    participants.each do |p|  
    puts ""      
      while p.hit_card?               
        (p.cards << (@deck.flick_a_card))  
      end
    end    
  end

  def set_game_result(gamblers) 
    gamblers.each do |p|      
      if self > p 
        p.set_vs_result(competitor_name:self.name,result:"Lose")        
        self.set_vs_result(competitor_name:p.name,result:"Win")        
      elsif self == p
        p.set_vs_result(competitor_name:self.name,result:"Draw")
        self.set_vs_result(competitor_name:p.name,result:"Draw")        
      else
        p.set_vs_result(competitor_name:self.name,result:"Win")
        self.set_vs_result(competitor_name:p.name,result:"Lose")        
      end
      p.set_gamble_history("["+p.cards.join(",")+"]",p.vs_result)
    end  
    self.set_gamble_history("["+self.cards.join(",")+"]", self.vs_result)   
  end
end

#--------------------------------------------------->>

class Gambler < Participant  
  def initialize(name)
    super(name)
  end

  def hit_card?
    total = calculate_cards_total 

    if is_blackjack?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Blakcjack!"
      return false
    elsif is_twentyone?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Twenty-One!"
      return false
    elsif is_bursted?
      puts "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, Burst!"
      return false
    else
      while true
        printf "#{name.green}:: Cards=#{show_cards.to_s.blue}, Total=#{calculate_cards_total.to_s.blue}, (#{'H'.brown})it one card or (#{'S'.brown})tay? "
        stay_or_hit = gets.chomp.upcase
        break if ['H','S'].include? stay_or_hit
      end 
      return stay_or_hit == 'H'
    end
  end

  def is_exit?    
    puts ""
    printf "#{name.brown}:: (#{'E'.brown})xit or Press any key to play again. "              
    gets.chomp.upcase == "E" 
  end
end

#--------------------------------------------------->>

class Card  
  attr_reader :suit, :number

  def initialize (suit,number)
    @suit = suit
    @number = number
  end

  def card_value
    if number == "A"
      "A"
    elsif ['J','Q','K'].include? self.number
      10
    else
      number.to_i
    end
  end

  def to_s
    "#{suit}#{number}"    
  end  
end

#--------------------------------------------------->>

class Deck
  DECK = 1 
  attr_accessor :cards

  def initialize
    @cards = []    
  end

  def is_cards_enough?
    (cards.count <  Deck::DECK * 52 / 2) ? false : true
  end

  def supplemnt_cards
    s=['♠','♥','♦','♣']
    n=['A','2','3','4','5','6','7','8','9','10','J','Q','K']
    c = (s.product n).map{ |e| Card.new(e[0],e[1]) } * Deck::DECK     
    @cards = @cards + c.shuffle!
  end

  def flick_a_card
    supplemnt_cards if !is_cards_enough?        
    @cards.shift    
  end
end

#--------------------------------------------------->>

class Game
  attr_reader :name, :delear, :gamblers
  
  def initialize
    @name = "Blackjack Game"  
    @participant = nil
    @delear = nil
    @gamblers =[]
  end
  
  def play
    system "clear"
    create_participants  
    while true
      break if !start_new_game 
    end
  end

  private
  def create_participants   
    @delear = Delear.new("Daniel")    
    puts "---------------------------------------------------------"
    puts "Your Ruby Version    : #{RUBY_VERSION}".red
    puts "Required Ruby Version: 2.1.1".red
    puts "---------------------------------------------------------"
    puts "Hi, My name is Daniel, I am a delear, nice to meet you !"
    while true
      printf "What's your name? "  
      name = gets.chomp    
      if !name.empty?        
        @gamblers << Gambler.new(name)
        printf "Add another gambler? (y/n)"  
        add_another_gambler = gets.chomp.upcase
        if add_another_gambler != "Y"              
          system "clear"
          break
        end
      end
    end    
  end

  def display_game_result
    puts ""
    puts "--------------------"
    puts "[Game Result]".blue
    puts "--------------------"        
    @gamblers.each do |p|                     
        e = p.gamble_history.last        
        i = p.gamble_history.count-1                                
        printf "Gambler => %s %s, cards=%s\nV.S\nDelear  => %s %s, cards=%s \n\n", p.name.brown, (e[:vs_result].values.join).brown, e[:cards].brown, @delear.name.brown, @delear.gamble_history[i][:vs_result][p.name].brown,@delear.gamble_history[i][:cards].brown                                                
    end 
  end

  def display_game_report
    puts ""
    puts "--------------------"
    puts "[Game Report]".blue
    puts "--------------------"
    puts ""
    @gamblers.each do |p|             
      puts "Gambler: #{p.name.brown} "
      puts "Delear : #{@delear.name.brown}"
      p.gamble_history.each_with_index do |e,i|
        printf "Round_#{i+1} |-> %s, %s vs %s \n", (e[:vs_result].values.join).brown, e[:cards].brown, @delear.gamble_history[i][:cards].brown
        printf ""
      end      
      puts ""
    end
  end

  def is_exit?
    @gamblers.each do |p|
      (p.is_exit?) ? @gamblers.delete(p) : p.play_again
    end
    if @gamblers.count > 0     
      @delear.play_again
      system "clear"     
      return false # play again
    else      
      puts "Bye!"
      return true # exit
    end
  end

  def start_new_game   
    puts "--------------------"
    puts "[start_new_game]".blue
    puts "--------------------"
    
    participants = @gamblers+ [@delear]    

    @delear.deal_cards(participants)               
    @delear.participant_stay_or_hit(participants) 
    @delear.set_game_result(@gamblers)
            
    display_game_result   
    display_game_report    

    return !is_exit?
  end
end

#--------------------------------------------------->>

# Here we go ===>
Game.new.play
#===============>

