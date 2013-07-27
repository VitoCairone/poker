class InvalidBetError < RuntimeError
end

class InvalidHandError < RuntimeError
end

class Deck
  def initialize
    @cards = [:hearts, :spades, :clubs, :diamonds].flat_map do |suit|
      (2..14).to_a.map { |rank| Card.new(rank, suit) }
    end
    @cards.shuffle
  end

  def deal(player, num)
    player.hand.add_cards(@cards.pop(num))
  end

  def count
    #this also should not exist
    @cards.count
  end
end

class Poker
  attr_accessor :pot, :bet_to_match
  attr_reader :deck
  RANK_HASH = {:high_card => 0,
               :pair => 1,
               :two_pair => 2,
               :three_of_a_kind => 3,
               :straight => 4,
               :flush => 5,
               :full_house => 6,
               :four_of_a_kind => 7,
               :straight_flush => 8,
               :royal_flush => 9}

  def initialize
    @deck = Deck.new
    @players = []
    @pot = 0
    @bet_to_match = 0
  end

  def add_player(player)
    @players << player
  end

  def betting_round
    zero_all_bets
    players_in = @players.select { |player| !player.folded }
    return if players_in.count == 1
    start_bet = @bet_to_match
    while true
      players_in.each do |player|
        player.get_action
      end
      players_in.select! { |player| !player.folded }
      break unless players_in.all? { |player| player.bet == @bet_to_match }
    end
  end

  def play_hand
    @deck = Deck.new
    @players.each { |player| player.hand = Hand.new }
    deal = Proc.new { |player| @deck.deal(player, 2) }
    @players.each(&deal)
    betting_round
    @players.each(&deal)
    betting_round
    @players.each { |player| @deck.deal(player, 1) }
    betting_round
    showdown!
    @players.select! { |player| player.chips > 0}
  end

  def run(num_players)
    @players = Array.new(num_players) { Player.new(self, 1000, "Bob") }
    while @players.count > 1
      play_hand
    end
  end

  def showdown!
    players_in = @players.select { |player| !player.folded }
    winner = players_in.first
    best_hand = players_in.first.hand
    players_in.each_with_index do |player, idx|
      if player.hand > best_hand
        winner = player
        best_hand = player.hand
      end
    end
    puts "#{winner.name} won the round with #{best_hand.hand_type}"
    winner.chips += @pot
    @pot = 0
  end

  def zero_all_bets
    @bet_to_match = 0
    @players.each { |player| player.bet = 0 }
  end

end

class Card
  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank, @suit = rank, suit
  end
end

class Player

  attr_reader :chips, :folded
  attr_accessor :hand, :bet, :name

  def initialize(game, chips, name)
    @game, @chips = game, chips
    @hand = Hand.new
    @bet = 0
    @folded = false
    @name = name
  end

  def bet(increase)
    if increase < 0 || increase > @chips
      raise InvalidBetError.new "You can't bet that amount"
    end
    if (@bet + increase) < @game.bet_to_match
      raise InvalidBetError.new "Bet at least #{@game.bet_to_match - @bet} or fold."
    end

    @bet += increase
    @chips -= increase
    @game.pot += increase
    @game.bet_to_match = @bet
  end

  def get_action
    begin
      puts "The current bet is #{@game.bet_to_match}."
      puts "[C]heck, [B]et, or [F]old?"
      input = gets.chomp.downcase.split(" ")
      case input.first
      when 'c'
        bet(0)
      when 'b'
        bet(Integer(input.last))
      when 'f'
        folded = true
      end
    rescue InvalidBetError, ArgumentError => e
      puts e.message
      retry
    end
  end

  def rename(name)
    self.name = "Bob"
  end

end

class Hand
  include Comparable
  def <=>(other_hand)
    self_rank, other_rank = self.hand_rank, other_hand.hand_rank
    basic_comp = self_rank.first <=> other_rank.first
    return basic_comp unless basic_comp == 0
    self_rank.last.each_with_index do |num, idx|
      comp = num <=> other_rank.last[idx]
      return comp unless comp == 0
    end
    0
  end

  def count
    #this method should not exist
    #but it is being used in tests because we do not know how to write tests
    @cards.count
  end

  def add_card(card)
    @cards << card
  end

  def add_cards(card_list)
    card_list.each { |card| add_card(card) }
  end

  def initialize
    @cards = []
  end

  def keys_of(hash, target)
    hash.select { |k, v| v == target }.keys.sort.reverse
  end

  def hand_type
    hand_rank.first.to_s.gsub("_", " ")
  end

  #[:straight_flush, [9]]
  #[:two_pair, [7, 3, 10]]
  def hand_rank
    types = {}
    raise InvalidHandError unless @cards.count == 5
    @cards.sort_by! { |card| card.rank }
    rank_counts = count_ranks
    suit_counts = count_suits

    flush = suit_counts.has_value?(5)
    straight = true
    @cards.each_with_index do |card, index|
      next if index == 0
      unless card.rank == @cards[index-1].rank + 1
        straight = false
        break
      end
    end
    straight = true if @cards == [2, 3, 4, 5, 14]
    three = rank_counts.has_value?(3)
    pair = rank_counts.has_value?(2)
    two_pair = rank_counts.select { |k, v| v == 2 }.length == 2
    return [:straight_flush, @cards.last.rank] if straight && flush
    return [:four_of_a_kind, keys_of(rank_counts, 4)] if rank_counts.has_value?(4)
    if three && pair
      return [:full_house, keys_of(rank_counts, 3) + keys_of(rank_counts, 2)]
    end
    return [:flush, @cards.map(&:rank).reverse] if flush
    return [:straight, @cards.last.rank] if straight
    if three
      return [:three_of_a_kind,
              keys_of(rank_counts, 3) + keys_of(rank_counts, 1)]
    end
    if two_pair
      return [:two_pair, keys_of(rank_counts, 2) + keys_of(rank_counts, 1)]
    end
    if pair
      return [:pair, keys_of(rank_counts, 2) + keys_of(rank_counts, 1)]
    end
    return [:high_card, @cards.map(&:rank).reverse]
  end

  def count_ranks
    rank_counts = Hash.new(0)
    @cards.each { |card| rank_counts[card.rank] += 1 }
    rank_counts
  end

  def count_suits
    suit_counts = Hash.new(0)
    @cards.each { |card| suit_counts[card.suit] += 1 }
    suit_counts
  end
end