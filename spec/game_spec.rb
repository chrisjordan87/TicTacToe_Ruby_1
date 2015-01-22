require_relative '../lib/game.rb'
require_relative '../lib/board.rb'
require_relative 'utils/stub_display.rb'
require_relative 'utils/stub_player.rb'

describe TTT::Game do
  let(:board) { TTT::Board.new }
  let(:stub_display) { TTT::StubDisplay.new }
  let(:stub_player_1) { TTT::StubPlayer.new }
  let(:stub_player_2) { TTT::StubPlayer.new }
  let(:game) { TTT::Game.new(board, stub_display, stub_player_1, stub_player_2) }

  it 'displays next player to move during a turn' do
    game.play_next_turn
    expect(stub_display.print_next_player_to_go_results).to include(stub_player_1)
  end

  it 'displays board during a turn' do
    game.play_next_turn
    expect(stub_display.render_board_results).to include(board)
  end

  it 'gets next move from player' do
    game.play_next_turn
    expect(stub_player_1.next_move_count).to be(1)
  end

  it 'adds move to board' do
    game.play_next_turn
    player_move = stub_player_1.next_move
    expect(board.added_moves[player_move]).to eq(stub_player_1)
  end

  it 'current player set to player 1 and not changed when no turns take place' do
    board.game_over_sequence(true)
    game.play
    expect(game.current_player).to eq(stub_player_1)
  end

  it 'current player is swapped to player 2 when two turns take place' do
    board.game_over_sequence(false, false, true)
    game.play
    expect(game.current_player).to eq(stub_player_2)
  end

  it 'current player is swapped to player 1 when three turns take place' do
    board.game_over_sequence(false, false, false, false, true)
    game.play
    expect(game.current_player).to eq(stub_player_1)
  end

  it 'plays next turn when play is triggered' do
    board.game_over_sequence(false, false, true)
    game.play
    expect(stub_player_1.next_move_count).to eq(1)
  end

  it 'prints tie after game ends in tie' do
    board.game_over_sequence(true)
    board.is_a_tie = true
    game.play
    expect(stub_display.print_tie_message_count).to eq(1)
  end

  it 'prints winner after game ends in win' do
    board.game_over_sequence(true)
    board.set_winner(stub_player_1)
    game.play
    expect(stub_display.print_winner_message_results).to include(stub_player_1)
  end
end
