require 'pry'

class Hand  

  @@compare_result = { "PP" => 0, "PR" => 1, "PS" => -1,
                       "RP" => -1, "RR" => 0, "RS" => 1,
                       "SP" => 1, "SR" => -1, "SS" => 0 }.freeze

  attr_reader :choice
  
  def initialize choice
    @choice = choice   
  end

  def self.compare_hand_choice (c_1,c_2)
    key = c_1 + c_2    
    @@compare_result[key] 
  end

  def <=> (another_hand)
    key = self.choice + another_hand.choice
    @@compare_result[key] 
  end
end 


class Participant  
  # constant variable reference frozen hash
  ROLE_TYPE = {computer:"COMPUTER", human:"HUMAN"}.freeze
  @@prs = ['P','R','S']

  attr_accessor :point
  attr_reader :role, :name, :hand
  
  def initialize (role, name)
    @role = role
    @name = name
    @point = 0
  end

  def choice  
    if @role == ROLE_TYPE[:computer]
      # computer  
      choice = @@prs.shuffle.first
      @hand = (Hand.new choice)
    elsif @role == ROLE_TYPE[:human]
      # human
      begin  
      printf "Hi, #{@name}, choice (P)aper (R)ock (S)cissor ? "
      choice = gets.chomp.upcase
      end until choice =~ /^[PRS]$/
      @hand = (Hand.new choice)
    end
  end
end


class Game

  def initialize
    @groups = []
    @players = {}
    welcome
  end

  def play
    system "clear"    
    @groups.push(@players.map { |k,v| k }) if @groups.count == 0
    begin       
      tmp_result =[]      
      @groups.each_with_index do |group,i|         
        if group.count > 1
          players_ready_to_fighting = @players.select {|name,participant| group.include? name}              
          puts "players = #{players_ready_to_fighting.map{|name,participant| name}} is fighting"            
          fighting_result = fighting players_ready_to_fighting                          
        end    
        (fighting_result == nil) ? tmp_result << group : fighting_result.each { |group| tmp_result << group }
      end             
      @groups = tmp_result unless tmp_result.count == 0
      remain = @groups.select {|group| group.count > 1}          
    end until remain.count == 0 
  end

  def show_fighting_result    
    puts "<< show_fighting_result >>"  
    @groups.reverse.flatten.each_with_index do |name,i|
      if i == 0
        printf "Rank_%-2s: %-15s => %s\n",(i+1),name,"The First Prize." 
      elsif i == @groups.count - 1
        printf "Rank_%-2s: %-15s => %s\n",(i+1),name,"The Last Place."
      else
         printf "Rank_%-2s: %-10s \n",(i+1),name
      end
    end
    puts "-----------------------------------------------------------------"  
  end

  private

  def welcome    
    system "clear"
    puts "______________________________________"
    puts "|                                     |"
    puts "| Welcome! Paper, Rock, Scissors Game |"
    puts "|                                     |"
    puts "______________________________________"

    add_player(Participant::ROLE_TYPE[:computer], "DaddyDanielT")

    while true
      puts ""
      puts "Add player:"
      
      while true 
        printf "What's your name ? "
        name = gets.chomp
        if name.length > 0
          (@players.keys.include? name) ? (puts "The name, '#{name}', has alread been used. Try another one, thanks.") : break        
        end
      end 

      while true      
        printf "You are 1)human 2)computer ? "
        role = gets.chomp
        if  ["1","2"].include? role
          role == "1" ? role = :human : role = :computer 
          add_player(Participant::ROLE_TYPE[role], name)   
          break
        else
          puts "Wrong input!! "
        end      
      end

      printf "(A)dd another player or press any key to fight! "
      exit = gets.chomp.upcase
      if exit != "A"
        puts ""
        puts "-----------------------------------------------------------------"
        break
      end
    end
  end

  def fighting(players)    
    participant_list = players.values
    # Player choice one from 'p','r','s'
    participant_list.each { |p| p.choice }
    hand_choice_name_lists= participant_list.map{ |player| [player.hand.choice,player.name] }.group_by { |e| e[0] }.map{ |k,v| [k, v.map { |i| i[1]}.join(",")] }.to_h
    participant_list.sort!{ |x,y| x.hand <=> y.hand }  
    if [1,3].include? hand_choice_name_lists.keys.count
      # draw game, back to choice again
      puts "#{hand_choice_name_lists} Draw game, back to choice again."      
    else      
      c_1 = hand_choice_name_lists.keys[0]
      c_2 = hand_choice_name_lists.keys[1]          
      compare_result = Hand.compare_hand_choice(c_1,c_2)    
      c_1_name_list = hand_choice_name_lists[c_1].split(",")
      c_2_name_list = hand_choice_name_lists[c_2].split(",")      
      # left:lose , right:win
      if compare_result == 1         
        puts "#{hand_choice_name_lists} Lose: #{c_2_name_list}  Win:  #{c_1_name_list}"
        puts "-----------------------------------------------------------------"
        return [c_2_name_list,c_1_name_list]
      else compare_result == -1
        puts "#{hand_choice_name_lists} Lose: #{c_1_name_list}  Win:  #{c_2_name_list}"
        puts "-----------------------------------------------------------------"
        return [c_1_name_list,c_2_name_list]
      end
    end  
  end

  def add_player(role,name)
    @players[name] = Participant.new(role,name)    
  end

end

# Here we go =====>
my_game = Game.new
my_game.play
my_game.show_fighting_result
# ================>








