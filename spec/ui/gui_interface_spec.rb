require 'spec_helper'
require 'lib/ui/gui_interface'
require 'lib/board'
require 'spec/stubs/stub_game'
require 'spec/helpers/board_helper'
require 'ostruct'
require 'ui/constants'

describe TTT::UI::GUIInterface do
  let(:board) { TTT::Board.new(3) }
  let(:board_helper) { TTT::BoardHelper.new }
  let(:position) {1}
  let(:stub_game){TTT::StubGame.new}
  let(:gui_interface){TTT::UI::GUIInterface.new(stub_game)}
  let(:game_model) { OpenStruct.new(:board => board, :current_player_mark => 'X') }

  before(:all) do
    @app = Qt::Application.new(ARGV)
  end

  it 'creates board with cells' do
    gui_interface.init_board(board)
    expect(gui_interface.cells.size).to be(stub_game.number_of_positions)
  end

  it 'deletes previous board when board is subsequently initiated' do
    gui_interface.init_board(board)
    widget_count_after_first_initiation = gui_interface.ui_grid.count
    gui_interface.init_board(board)
    widget_count_after_second_initiation = gui_interface.ui_grid.count

    expect(widget_count_after_first_initiation).to eq(widget_count_after_second_initiation)
  end

  it 'validates user move when current player is human' do
    game_model.current_player_is_computer = false
    stub_game.set_model_data(game_model)
    gui_interface.board_clicked(position)
    expect(stub_game.move_valid_called?).to be true
  end

  it 'propogates move to game when current player is human' do
    game_model.current_player_is_computer = false
    stub_game.set_model_data(game_model)

    gui_interface.board_clicked(position)
    expect(stub_game.play_turn_called?).to be true
  end

  it 'updates board when human has played a move' do
    game_model.current_player_is_computer = false
    stub_game.set_model_data(game_model)

    gui_interface.board_clicked(position)
    expect(gui_interface.status_label.text).to include("X's turn")
  end

  it 'prints invalid move message' do
    game_model.current_player_is_computer = false
    stub_game.set_model_data(game_model)
    stub_game.all_moves_are_invalid
    gui_interface.board_clicked(position)
    expect(gui_interface.status_label.text).to include(TTT::UI::INVALID_MOVE_MESSAGE)
  end

  it 'populates game choices selection menu from Game object' do
    expect(gui_interface.game_choices.count).to eq(TTT::Game::GAME_TYPES.size)
  end

  it 'default game to be created is first of Games types' do
    expect(gui_interface.next_game_type_to_build).to eq(TTT::Game.default_game_type)
  end

  it 'populates size choices selection menu from Game' do
    expect(gui_interface.game_sizes.count).to eq(TTT::Game::BOARD_SIZES.size)
  end

  it 'default board size is first option provided by Game' do
    expect(gui_interface.next_board_size_to_build).to eq(TTT::Game.default_board_size)
  end

  it 'prepares selected board size to be the next board size to build' do
    gui_interface.prepare_board_size('some board size')
    expect(gui_interface.next_board_size_to_build).to eq('some board size')
  end

  it 'prepared selected game type to be the next game type to build' do
    gui_interface.prepare_next_game_type_to_create('some game type')
    expect(gui_interface.next_game_type_to_build).to eq('some game type')
  end

  it 'creates game with selected properties' do
    game = gui_interface.create_new_game
    expect(game).to be_kind_of(TTT::Game)
    expect(game.row_size).to eq(gui_interface.next_board_size_to_build)
  end

  it 'calls play turn when game is not over' do
    stub_game.play_turn_ends_game
    stub_game.set_model_data(game_model)
    game_model.current_player_is_computer = true
    gui_interface.start_game(stub_game)
    expect(stub_game.play_turn_called?).to be(true)
  end

  it 'does not call play turn when current player is human' do
    game_model.current_player_is_computer = false
    stub_game.set_model_data(game_model)
    gui_interface.start_game(stub_game)
    expect(stub_game.play_turn_called?).to be(false)
  end

  it 'prints out board when game turn is played' do
    stub_game.play_turn_ends_game
    game_model.current_player_is_computer = true
    stub_game.set_model_data(game_model)
    gui_interface.start_game(stub_game)

    assert_board_is_correct
  end

  it 'prints out next player turn when turn is played' do
    stub_game.play_turn_ends_game
    game_model.current_player_is_computer = true
    stub_game.set_model_data(game_model)
    gui_interface.start_game(stub_game)

    expect(gui_interface.status_label.text).to include("X's turn")
  end

  it 'prints out draw when game is a tie' do
    game_model.status = TTT::Game::DRAW
    stub_game.set_model_data(game_model)
    gui_interface.start_game(stub_game)

    expect(gui_interface.status_label.text).to include(TTT::UI::TIE_MESSAGE)
  end

  it 'prints out winner message when game has been won' do
    game_model.status = TTT::Game::WON
    game_model.winner = 'O'
    stub_game.set_model_data(game_model)
    gui_interface.start_game(stub_game)

    expect(gui_interface.status_label.text).to include(TTT::UI::WINNING_MESSAGE % 'O')
  end

  def generate_board
    board = TTT::Board.new(3)
    board_helper = TTT::BoardHelper.new
    board_helper.populate_board_with_tie(board, 'X', 'O')
    board
  end

  def assert_board_is_correct
    gui_interface.cells.each_with_index do |cell, index|
      expect(cell.text).to eq(board.get_mark_at_position(index))
    end
  end
end
