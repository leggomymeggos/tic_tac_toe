require_relative '../game'

describe 'Game' do
  let(:game){ Game.new }

  it 'has players' do
    expect( game.players ).not_to be nil
  end

  it 'has a board' do
    expect( game.board ).not_to be nil
  end

  describe '#players' do
    it 'has two players' do
      expect( game.players.length ).to be 2
    end

    it 'has one Human player and one Computer player' do
      expect(game.players).to include(Human, Computer)
    end
  end

  describe '#player1' do
    it 'is the first player' do
      expect(game.player1).to eq(game.players[0])
    end
  end

  describe '#player2' do
    it 'is the second player' do
      expect(game.player2).to eq(game.players[1])
    end
  end

  describe '#mark_space' do
    it 'marks the space where requested' do
      expect{ game.mark_space("top left", game.player2) }.to change{ game.board.rows[0][0] }
      expect{ game.mark_space("center", game.player1) }.to change{ game.board.rows[1][1] }
    end

    it 'marks the space with the player\'s marker' do
      game.mark_space("bottom right", game.player2)
      expect( game.board.grid[:bottom_right] ).to eq( game.player2.marker )
    end

    it 'doesn\'t let a player change an already populated space' do
      game.mark_space("center", game.player2)
      game.mark_space("center", game.player1)
      expect( game.board.grid[:center] ).to eq( game.player2.marker )
    end

    it 'works with symbols' do
      expect{ game.mark_space(:center, game.player1) }.not_to raise_error
      expect{ game.mark_space(:top_right, game.player1) }.to change{ game.board.rows[0][2] }
    end
  end

  describe '#add_underscore' do
    it 'replaces spaces with underscores' do
      expect( game.add_underscore("top left") ).to eq("top_left")
    end
  end

  describe '#winner' do
    it 'returns the winner if there is a filled row' do
      row_winner = row_win( game.player2 )
      expect( row_winner.winner ).to eq( row_winner.player2 )
    end

    it 'returns the winner if there is a filled column' do
      column_win( game.player1 )
      expect( game.winner ).to eq( game.player1 )
    end

    it 'returns the winner if there is a filled diagonal' do
      diagonal_win( game.player1 )
      expect( game.winner ).to eq( game.player1 )
    end
  end

  describe '#finished?' do
    it 'is true if there is a winner' do
      diagonal_win( game.player2 )
      expect( game.finished? ).to be true
    end

    it 'is true if all the spaces on the board are filled' do
      fill_board
      expect( game.finished? ).to be true
    end
  end

  context "two computer players" do
    let(:tic_tac_computer){ Game.new(player1: "computer", player2: "computer") }
    it 'initializes with two computer players' do
      expect(tic_tac_computer.players.all? { |player| player.is_a? Computer }).to be true
    end

    it 'sets the players with different markers' do
      expect(tic_tac_computer.player1.marker).not_to eq(tic_tac_computer.player2.marker)
    end

    it 'always results in a tie' do
      computer_game = computers_fight
      expect(computer_game.winner).to be nil
    end

    it 'never lets player 1 win' do
      computer_game = computers_fight
      expect(computer_game.winner).not_to be computer_game.player1
    end

    it 'always has players take all their turns' do
      computer_game = computers_fight
      expect(computer_game.board.grid.values.count(computer_game.player1.marker)).to eq 5
      expect(computer_game.board.grid.values.count(computer_game.player2.marker)).to eq 4
    end

    describe '#mark_space' do
      it 'updates the game board' do
        expect{ tic_tac_computer.mark_space("center", tic_tac_computer.player1) }.to change{ tic_tac_computer.board.grid }
      end

      it 'updates the computer board' do
        expect{ tic_tac_computer.mark_space("center", tic_tac_computer.player1) }.to change{ tic_tac_computer.player1.board.grid }
      end

      it 'updates the game and computer board in the same way' do
        tic_tac_computer.mark_space("center", tic_tac_computer.player1)
        expect(tic_tac_computer.board).to eq(tic_tac_computer.player1.board)
        expect(tic_tac_computer.board.grid).to eq(tic_tac_computer.player1.board.grid)
      end

      it 'updates the other player\'s board when the other player is a computer' do
        tic_tac_computer.mark_space("center", tic_tac_computer.player1)
        expect(tic_tac_computer.player2.board.grid).to eq(tic_tac_computer.player1.board.grid)
      end
    end
  end

  def computers_fight
    until tic_tac_computer.finished?
      tic_tac_computer.mark_space(tic_tac_computer.player1.next_move, tic_tac_computer.player1)
      tic_tac_computer.mark_space(tic_tac_computer.player2.next_move, tic_tac_computer.player2) unless tic_tac_computer.finished?
    end
    # binding.pry
    tic_tac_computer
  end

  def diagonal_win(player)
    game.mark_space("top right", player)
    game.mark_space("center", player)
    game.mark_space("bottom left", player)
    game
  end

  def row_win(player)
    game.mark_space("middle left", player)
    game.mark_space("center", player)
    game.mark_space("middle right", player)
    game
  end

  def column_win(player)
    game.mark_space("top right", player)
    game.mark_space("middle right", player)
    game.mark_space("bottom right", player)
    game
  end

  def fill_board
    game.mark_space("top right", game.player1)
    game.mark_space("middle right", game.player1)
    game.mark_space("bottom right", game.player2)
    game.mark_space("top center", game.player2)
    game.mark_space("center", game.player1)
    game.mark_space("bottom center", game.player2)
    game.mark_space("top left", game.player2)
    game.mark_space("middle left", game.player2)
    game.mark_space("bottom left", game.player1)
  end
end
