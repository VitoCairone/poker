require 'rspec'
require 'poker'


describe "#deck" do
  subject(:deck) { Deck.new }
  let(:player) { Player.new(nil, 0) }

  it "starts with 52 cards" do
    expect(deck.count).to eq(52)
  end

  it "has no duplicate cards" do
    pending "Because it's hard :("
    expect(gdeck.uniq).to eq(game.deck)
  end

  it "shuffles the cards" do
    game2 = Poker.new
    expect(deck).to_not eq(game2.deck)
  end

  it "reduces the deck when cards are dealt" do
    deck.deal(player, 5)
    expect(deck.count).to eq(47)
  end

  it "gives cards to a player" do
    deck.deal(player, 5)
    expect(player.hand.count).to eq(5)
  end

  it "gives additional cards to a player" do
    deck.deal(player, 5)
    deck.deal(player, 2)
    expect(player.hand.count).to eq(7)
  end
end

describe "Player" do
  describe "#bet" do
    let(:game) { Poker.new }
    subject(:player) { Player.new(game, 1000) }

    it "adds its bet to the pot" do
      player.bet(20)
      expect(game.pot).to eq(20)
    end

    it "removes its bet from its chips" do
      player.bet(20)
      expect(player.chips).to eq(980)
    end

    it "increases the bet_to_match" do
      player.bet(20)
      expect(game.bet_to_match).to eq(20)
    end

    it "raises an error with illegal amounts" do
      expect { player.bet(-10) }.to raise_error(InvalidBetError)
    end

    it "raises an error when player doesn't bet enough" do
      game.stub(:bet_to_match) { 100 }
      expect { player.bet(50) }.to raise_error(InvalidBetError)
    end
  end

  describe "#fold" do
    let(:game) { Game.new }
    subject(:player) { Player.new(game, 1000) }
  end
end

describe "Hand" do

  describe "#add_card" do
    it "adds a card" do
      hand = Hand.new
      #double('card', :rank => 8, :suit => :hearts )
      hand.add_card(double('card', :rank => 8, :suit => :hearts ))
      expect(hand.count).to eq(1)
    end
  end

  describe "#hand_type" do

    let(:hand) { Hand.new }

    it "finds straight flushes" do
      hand.add_card( double("ace", :rank => 14, :suit => :spades))
      hand.add_card( double("king", :rank => 13, :suit => :spades))
      hand.add_card( double("queen", :rank => 12, :suit => :spades))
      hand.add_card( double("jack", :rank => 11, :suit => :spades))
      hand.add_card( double("ten", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("straight flush")
    end

    it "finds 4-of-a-kind" do
      hand.add_card( double("ace_heart", :rank => 14, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("ace_club", :rank => 14, :suit => :clubs))
      hand.add_card( double("ace_diamond", :rank => 14, :suit => :diamonds))
      hand.add_card( double("ten", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("four of a kind")
    end

    it "finds full house" do
      hand.add_card( double("ace_heart", :rank => 14, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("ace_club", :rank => 14, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      hand.add_card( double("ten_spade", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("full house")
    end

    it "finds flush" do
      hand.add_card( double("ace", :rank => 14, :suit => :spades))
      hand.add_card( double("king", :rank => 13, :suit => :spades))
      hand.add_card( double("six", :rank => 6, :suit => :spades))
      hand.add_card( double("jack", :rank => 11, :suit => :spades))
      hand.add_card( double("ten", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("flush")
    end

    it "finds straight" do
      hand.add_card( double("ace", :rank => 14, :suit => :hearts))
      hand.add_card( double("king", :rank => 13, :suit => :spades))
      hand.add_card( double("queen", :rank => 12, :suit => :spades))
      hand.add_card( double("jack", :rank => 11, :suit => :spades))
      hand.add_card( double("ten", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("straight")
    end

    it "finds 3-of-a-kind" do
      hand.add_card( double("ace_heart", :rank => 14, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("ace_club", :rank => 14, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      hand.add_card( double("nine_spade", :rank => 9, :suit => :spades))
      expect(hand.hand_type).to eq("three of a kind")
    end

    it "finds 2 pair" do
      hand.add_card( double("ace_heart", :rank => 14, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("nine_club", :rank => 9, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      hand.add_card( double("ten_spade", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("two pair")
    end

    it "finds pair" do
      hand.add_card( double("six_heart", :rank => 6, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("nine_club", :rank => 9, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      hand.add_card( double("ten_spade", :rank => 10, :suit => :spades))
      expect(hand.hand_type).to eq("pair")
    end

    it "finds high card" do
      hand.add_card( double("six_heart", :rank => 6, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("nine_club", :rank => 9, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      hand.add_card( double("four_spade", :rank => 4, :suit => :spades))
      expect(hand.hand_type).to eq("high card")
    end

    it "raises error unless hand is 5 cards" do
      hand.add_card( double("six_heart", :rank => 6, :suit => :hearts))
      hand.add_card( double("ace_spade", :rank => 14, :suit => :spades))
      hand.add_card( double("nine_club", :rank => 9, :suit => :clubs))
      hand.add_card( double("ten_diamond", :rank => 10, :suit => :diamonds))
      expect { hand.hand_type }.to raise_error(InvalidHandError)
    end
  end

  describe "#compare_hands" do
    it "returns the better hand" do
    end
  end

end