# frozen_string_literal: true

require_relative '../lib/chess-engine/game'

describe ChessEngine::Game do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }
  let(:blank_board) { double('board', units: []) }
  subject(:blank_game) { described_class.new([white_player, black_player]) }

  before do
    blank_game.instance_variable_set(:@board, blank_board)
    blank_game.instance_variable_set(:@game_log, [])
  end

  describe '#unit_allowed_actions' do
    subject(:game_allowed) { blank_game }
    let(:board_allowed) { ChessEngine::Board.new }

    matcher :match_locations do |check_locations, action_command_type = nil|
      match do |actions|
        test_actions = action_command_type ? actions.select { |action| action.is_a?(action_command_type) } : actions
        test_actions_moves = test_actions.map { |action| action.moves }.flatten
        test_actions_locations = test_actions_moves.map { |move| move&.location }
        check_locations.each do |check_location|
          return false unless test_actions_locations.include?(check_location)
        end
        true
      end
    end

    before do
      blank_game.instance_variable_set(:@board, board_allowed)
    end

    context 'moves inside boundary' do
      it 'returns all moves' do
        pawn_unit = ChessEngine::Units::Pawn.new('c2', white_player)
        knight_unit = ChessEngine::Units::Knight.new('e5', black_player)
        king_unit = ChessEngine::Units::King.new('f6', white_player)
        board_allowed.add_unit(pawn_unit)
        pawn_result = game_allowed.unit_allowed_actions(pawn_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(knight_unit)
        knight_result = game_allowed.unit_allowed_actions(knight_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(king_unit)
        king_result = game_allowed.unit_allowed_actions(king_unit)

        expect(pawn_result).to match_locations(%w[c3 c4], ChessEngine::Actions::NormalMoveCommand)
        expect(knight_result).to match_locations(%w[g4 f3 g6 f7 d7 c6 c4 d3], ChessEngine::Actions::NormalMoveCommand)
        expect(king_result).to match_locations(%w[g5 g6 g7 f5 f7 e5 e6 e7], ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'moves outside of boundary' do
      it 'limits moves' do
        pawn_unit = ChessEngine::Units::Pawn.new('c8', white_player)
        rook_unit = ChessEngine::Units::Rook.new('c3', black_player)
        knight_unit = ChessEngine::Units::Knight.new('h8', black_player)
        bishop_unit = ChessEngine::Units::Bishop.new('e2', white_player)
        queen_unit = ChessEngine::Units::Queen.new('b7', black_player)
        king_unit = ChessEngine::Units::King.new('h8', white_player)

        board_allowed.add_unit(pawn_unit)
        pawn_result = game_allowed.unit_allowed_actions(pawn_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(rook_unit)
        rook_result = game_allowed.unit_allowed_actions(rook_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(knight_unit)
        knight_result = game_allowed.unit_allowed_actions(knight_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(bishop_unit)
        bishop_result = game_allowed.unit_allowed_actions(bishop_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(queen_unit)
        queen_result = game_allowed.unit_allowed_actions(queen_unit)
        game_allowed.instance_variable_set(:@allowed_actions, {})
        board_allowed.clear_units.add_unit(king_unit)
        king_result = game_allowed.unit_allowed_actions(king_unit)

        expect(pawn_result).to be_empty
        expect(rook_result).to match_locations(%w[c1 c2 c4 c5 c6 c7 c8 a3 b3 d3 e3 f3 g3 h3],
                                               ChessEngine::Actions::NormalMoveCommand)
        expect(knight_result).to match_locations(%w[f7 g6], ChessEngine::Actions::NormalMoveCommand)
        expect(bishop_result).to match_locations(%w[d1 f1 d3 c4 b5 a6 f3 g4 h5],
                                                 ChessEngine::Actions::NormalMoveCommand)
        expect(queen_result).to match_locations(%w[a8 a7 a6 b8 c8 c7 d7 e7 f7 g7 h7 c6 d5 e4 f3 g2 h1 b6 b5 b4
                                                   b3 b2 b1], ChessEngine::Actions::NormalMoveCommand)
        expect(king_result).to match_locations(%w[h7 g7 g8], ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'units are blocking moves' do
      it 'returns all moves that are not blocked by units' do
        blocking_pawn = ChessEngine::Units::Pawn.new('e4', black_player)
        bishop_unit = ChessEngine::Units::Bishop.new('c6', white_player)
        rook_unit = ChessEngine::Units::Rook.new('e6', white_player)
        queen_unit = ChessEngine::Units::Queen.new('g4', white_player)

        allow(board_allowed).to receive(:units).and_return([blocking_pawn, bishop_unit, rook_unit, queen_unit])

        bishop_result = game_allowed.unit_allowed_actions(bishop_unit)
        rook_result = game_allowed.unit_allowed_actions(rook_unit)
        queen_result = game_allowed.unit_allowed_actions(queen_unit)

        expect(bishop_result).to match_locations(%w[b7 a8 b5 a4 d5 d7 e8], ChessEngine::Actions::NormalMoveCommand)
        expect(rook_result).to match_locations(%w[e7 e8 d6 e5 f6 g6 h6], ChessEngine::Actions::NormalMoveCommand)
        expect(queen_result).to match_locations(%w[h4 h5 h3 g5 g6 g7 g8 g3 g2 g1 e2 d1 f3 f4 f5],
                                                ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'unblocked enemies in move range' do
      it 'allows attack' do
        queen = ChessEngine::Units::Queen.new('f6', black_player)
        enemy_queen = ChessEngine::Units::Queen.new('f1', white_player)
        enemy_knight = ChessEngine::Units::Knight.new('d5', white_player)
        enemy_pawn = ChessEngine::Units::Pawn.new('d4', white_player)
        enemy_bishop = ChessEngine::Units::Bishop.new('f8', white_player)

        allow(board_allowed).to receive(:units).and_return([queen, enemy_queen, enemy_knight, enemy_pawn, enemy_bishop])

        queen_result = game_allowed.unit_allowed_actions(queen)
        enemy_knight_result = game_allowed.unit_allowed_actions(enemy_knight)

        expect(queen_result).to match_locations(%w[f1 f8 d4], ChessEngine::Actions::AttackMoveCommand)
        expect(enemy_knight_result).to match_locations(%w[f6], ChessEngine::Actions::AttackMoveCommand)
      end
    end

    context 'blocked enemies in move range' do
      it 'do not allow attack' do
        white_rook = ChessEngine::Units::Rook.new('a1', white_player)
        white_pawn = ChessEngine::Units::Pawn.new('a2', white_player)
        black_rook = ChessEngine::Units::Rook.new('a6', black_player)
        black_bishop = ChessEngine::Units::Bishop.new('c1', black_player)

        allow(board_allowed).to receive(:units).and_return([white_rook, white_pawn, black_rook, black_bishop])

        white_rook_result = game_allowed.unit_allowed_actions(white_rook)
        black_rook_result = game_allowed.unit_allowed_actions(black_rook)

        expect(white_rook_result).to match_locations(%w[c1], ChessEngine::Actions::AttackMoveCommand)
        expect(black_rook_result).to match_locations(%w[a2], ChessEngine::Actions::AttackMoveCommand)
      end
    end

    context 'enemy pawn just moved two spaces' do
      let(:enemy_pawn_jumped_two) { ChessEngine::Units::Pawn.new('d4', white_player) }

      before do
        allow(game_allowed).to receive(:last_action).and_return(double('action',
                                                                       moves: [double('move',
                                                                                      unit: enemy_pawn_jumped_two, location: 'd4', from_location: 'd2')]))
        allow(game_allowed).to receive(:unit_actions)
      end

      it 'adjacent pawn can en passant' do
        adjacent_pawn = ChessEngine::Units::Pawn.new('e4', black_player)
        board_allowed.add_unit(enemy_pawn_jumped_two, adjacent_pawn)
        adjacent_pawn_result = game_allowed.unit_allowed_actions(adjacent_pawn)
        expect(adjacent_pawn_result).to match_locations(['d3'], ChessEngine::Actions::EnPassantCommand)
      end

      it 'non-adjacent pawn cannot en passant' do
        non_adjacent_pawn = ChessEngine::Units::Pawn.new('f4', black_player)
        board_allowed.add_unit(enemy_pawn_jumped_two, non_adjacent_pawn)
        non_adjacent_pawn_result = game_allowed.unit_allowed_actions(non_adjacent_pawn)
        en_passant_move_result = non_adjacent_pawn_result.detect do |action|
          action.is_a?(ChessEngine::Actions::EnPassantCommand)
        end
        expect(en_passant_move_result).to be(nil)
      end
    end

    context 'pawn has not moved' do
      let(:new_pawn) { ChessEngine::Units::Pawn.new('h7', black_player) }
      let(:log_double) { double('game_log', last_action: nil) }

      before do
        allow(blank_board).to receive(:units).and_return([new_pawn])
      end

      it 'allowed to double move' do
        board_allowed.add_unit(new_pawn)
        result = game_allowed.unit_allowed_actions(new_pawn)
        expect(result).to match_locations(%w[h5 h6], ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'pawn has moved' do
      let(:moved_pawn) { ChessEngine::Units::Pawn.new('h6', black_player) }

      before do
        allow(blank_board).to receive(:units).and_return([moved_pawn])
        allow(game_allowed).to receive(:unit_actions).with(moved_pawn).and_return({ action: :normal_move,
                                                                                    last_location: 'h7' })
      end

      it 'not allowed to double move' do
        board_allowed.add_unit(moved_pawn)
        result = game_allowed.unit_allowed_actions(moved_pawn)
        expect(result).not_to match_locations(['h4'], ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'pawn has not moved, but is blocked by another unit' do
      let(:new_pawn) { ChessEngine::Units::Pawn.new('h7', black_player) }
      let(:blocking_friendly) { ChessEngine::Units::Knight.new('h6', black_player) }
      let(:enemy_on_space) { ChessEngine::Units::Rook.new('h5', white_player) }

      it 'not allowed to double move' do
        allow(board_allowed).to receive(:units).and_return([new_pawn, blocking_friendly])
        blocking_friendly_result = game_allowed.unit_allowed_actions(new_pawn)

        expect(blocking_friendly_result).not_to match_locations(['h5'], ChessEngine::Actions::NormalMoveCommand)
      end
    end

    context 'king and rook have not moved and no units blocking path' do
      let(:white_queenside_rook) { ChessEngine::Units::Rook.new('a1', white_player) }
      let(:black_queenside_rook) { ChessEngine::Units::Rook.new('a8', black_player) }
      let(:white_kingside_rook) { ChessEngine::Units::Rook.new('h1', white_player) }
      let(:black_kingside_rook) { ChessEngine::Units::Rook.new('h8', black_player) }
      let(:white_king) { ChessEngine::Units::King.new('e1', white_player) }
      let(:black_king) { ChessEngine::Units::King.new('e8', black_player) }

      before do
        allow(game_allowed).to receive(:unit_actions)
        board_allowed.add_unit(white_queenside_rook, black_queenside_rook,
                               white_kingside_rook, black_kingside_rook,
                               white_king, black_king)
      end

      it 'can castle' do
        white_king_result = game_allowed.unit_allowed_actions(white_king)
        white_queenside_rook_result = game_allowed.unit_allowed_actions(white_queenside_rook)
        white_kingside_rook_result = game_allowed.unit_allowed_actions(white_kingside_rook)
        black_king_reuslt = game_allowed.unit_allowed_actions(black_king)
        black_queenside_king_result = game_allowed.unit_allowed_actions(black_queenside_rook)
        black_kingside_rook_result = game_allowed.unit_allowed_actions(black_kingside_rook)

        expect(white_king_result).to match_locations(['c1'], ChessEngine::Actions::QueensideCastleCommand)
      end
    end

    context 'king and rook have not moved but units blocking path' do
      let(:black_queenside_rook) { ChessEngine::Units::Rook.new('a8', black_player) }
      let(:black_kingside_rook) { ChessEngine::Units::Rook.new('h8', black_player) }
      let(:black_king) { ChessEngine::Units::King.new('e8', black_player) }
      let(:white_bishop) { ChessEngine::Units::Bishop.new('g8', white_player) }
      let(:black_queen) { ChessEngine::Units::Queen.new('d8', white_player) }

      before do
        board_allowed.add_unit(black_queenside_rook, black_kingside_rook, black_king,
                               white_bishop, black_queen)
      end

      it 'cannot castle' do
        black_queenside_rook_result = game_allowed.unit_allowed_actions(black_queenside_rook)
        black_kingside_rook_result = game_allowed.unit_allowed_actions(black_kingside_rook)
        black_king_result = game_allowed.unit_allowed_actions(black_king)

        expect(black_queenside_rook_result).not_to match_locations(['d8'], ChessEngine::Actions::QueensideCastleCommand)
        expect(black_kingside_rook_result).not_to match_locations(['f8'], ChessEngine::Actions::KingsideCastleCommand)
        expect(black_king_result).not_to match_locations(['g8'], ChessEngine::Actions::KingsideCastleCommand)
        expect(black_king_result).not_to match_locations(['c8'], ChessEngine::Actions::QueensideCastleCommand)
      end
    end

    context 'king and rook have not moved but king move spaces are under attack' do
      let(:white_queenside_rook) { ChessEngine::Units::Rook.new('a1', white_player) }
      let(:white_kingside_rook) { ChessEngine::Units::Rook.new('h1', white_player) }
      let(:white_king) { ChessEngine::Units::King.new('e1', white_player) }
      let(:black_rook) { ChessEngine::Units::Rook.new('f8', black_player) }
      let(:black_knight) { ChessEngine::Units::Knight.new('e3', black_player) }

      before do
        board_allowed.add_unit(white_queenside_rook, white_kingside_rook, white_king,
                               black_rook, black_knight)
      end

      it 'cannot castle' do
        queenside_rook_result = game_allowed.unit_allowed_actions(white_queenside_rook)
        kingside_rook_result = game_allowed.unit_allowed_actions(white_kingside_rook)
        king_result = game_allowed.unit_allowed_actions(white_king)

        expect(queenside_rook_result).not_to match_locations(['d1'], ChessEngine::Actions::QueensideCastleCommand)
        expect(kingside_rook_result).not_to match_locations(['f1'], ChessEngine::Actions::KingsideCastleCommand)
        expect(king_result).not_to match_locations(['g1'], ChessEngine::Actions::KingsideCastleCommand)
        expect(king_result).not_to match_locations(['c1'], ChessEngine::Actions::QueensideCastleCommand)
      end
    end

    context 'king or rook have moved' do
      let(:queenside_rook) { ChessEngine::Units::Rook.new('a1', white_player) }
      let(:kingside_rook) { ChessEngine::Units::Rook.new('h1', white_player) }
      let(:king) { ChessEngine::Units::King.new('e1', white_player) }

      before do
        board_allowed.add_unit(queenside_rook, kingside_rook, king)
        allow(game_allowed).to receive(:unit_actions).and_return({ action: :normal_move })
      end

      it 'cannot castle' do
        queenside_rook_result = game_allowed.unit_allowed_actions(queenside_rook)
        kingside_rook_result = game_allowed.unit_allowed_actions(kingside_rook)
        king_result = game_allowed.unit_allowed_actions(king)

        expect(queenside_rook_result).not_to match_locations(['d1'], ChessEngine::Actions::QueensideCastleCommand)
        expect(kingside_rook_result).not_to match_locations(['f1'], ChessEngine::Actions::KingsideCastleCommand)
        expect(king_result).not_to match_locations(['g1'], ChessEngine::Actions::KingsideCastleCommand)
        expect(king_result).not_to match_locations(['c1'], ChessEngine::Actions::QueensideCastleCommand)
      end
    end
  end

  describe '#stalemate?' do
    subject(:game_stalemate) { blank_game }
    let(:board_stalemate) { ChessEngine::Board.new }
    let(:black_king) { ChessEngine::Units::King.new('a8', black_player) }
    let(:black_queen) { ChessEngine::Units::Queen.new('g8', black_player) }
    let(:black_rook1) { ChessEngine::Units::Rook.new('h8', black_player) }
    let(:black_pawn) { ChessEngine::Units::Pawn.new('a5', black_player) }
    let(:black_rook2) { ChessEngine::Units::Rook.new('a2', black_player) }
    let(:white_pawn1) { ChessEngine::Units::Pawn.new('a4', white_player) }
    let(:white_pawn2) { ChessEngine::Units::Pawn.new('c5', white_player) }
    let(:white_bishop) { ChessEngine::Units::Bishop.new('h6', white_player) }
    let(:white_king) { ChessEngine::Units::King.new('h1', white_player) }

    before do
      allow(game_stalemate).to receive(:board).and_return(board_stalemate)
      board_stalemate.add_unit(black_king, black_queen,
                               black_rook1,
                               black_pawn, black_rook2,
                               white_pawn1, white_pawn2,
                               white_bishop, white_king)
    end

    context 'king is not in check and a piece can move without putting it in check' do
      it 'returns false' do
        expect(game_stalemate).not_to be_stalemate(white_king)
      end
    end

    context 'king is not in check, but any move will put it in check' do
      it 'returns true' do
        black_knight = ChessEngine::Units::Knight.new('c6', black_player)
        game_stalemate.board.add_unit(black_knight)
        expect(game_stalemate).to be_stalemate(white_king)
      end
    end
  end

  describe '#check?' do
    let(:king) { ChessEngine::Units::King.new('b2', white_player) }
    let(:board_check) { ChessEngine::Board.new }
    subject(:game_check) { blank_game }

    before do
      allow(game_check).to receive(:board).and_return(board_check)
    end

    context 'king unit is in check' do
      it 'returns true' do
        enemy_bishop = ChessEngine::Units::Bishop.new('f6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(game_check).to be_check(king)
      end
    end

    context 'king unit is not in check' do
      it 'returns false' do
        enemy_bishop = ChessEngine::Units::Bishop.new('e6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(game_check).not_to be_check(king)
      end
    end
  end

  describe '#checkmate?' do
    let(:white_king) { ChessEngine::Units::King.new('h1', white_player) }
    let(:black_rook) { ChessEngine::Units::Rook.new('g5', black_player) }
    let(:black_knight) { ChessEngine::Units::Knight.new('f2', black_player) }
    let(:board_checkmate) { ChessEngine::Board.new }
    subject(:game_checkmate) { blank_game }

    before do
      allow(game_checkmate).to receive(:board).and_return(board_checkmate)
      board_checkmate.add_unit(white_king, black_rook, black_knight)
    end

    context 'king is in check but still has possible moves' do
      it 'returns false' do
        black_bishop = ChessEngine::Units::Bishop.new('c8', black_player)
        board_checkmate.add_unit(black_bishop)
        expect(game_checkmate).not_to be_checkmate(white_king)
      end
    end

    context 'king is in check and has no possible moves' do
      it 'returns true' do
        black_bishop = ChessEngine::Units::Bishop.new('b8', black_player)
        board_checkmate.add_unit(black_bishop)
        expect(game_checkmate).to be_checkmate(white_king)
      end
    end
  end

  describe '#can_promote_last_unit?' do
    subject(:game_can_promote) { blank_game }
    let(:board_can_promote) { double('board') }

    context 'pawn is on last space' do
      it 'returns true' do
        promotable_pawn = ChessEngine::Units::Pawn.new('b1', black_player)
        allow(game_can_promote).to receive(:last_unit).and_return(promotable_pawn)
        allow(board_can_promote).to receive(:delta_location).with('b1', [-1, 0]).and_return(nil)
        allow(game_can_promote).to receive(:board).and_return(board_can_promote)
        expect(game_can_promote).to be_can_promote_last_unit
      end
    end

    context 'pawn is not on last space' do
      it 'returns false' do
        promotable_pawn = ChessEngine::Units::Pawn.new('b2', black_player)
        allow(board_can_promote).to receive(:delta_location).with('b2', [-1, 0]).and_return('b1')
        allow(game_can_promote).to receive(:board).and_return(board_can_promote)
        expect(game_can_promote).not_to be_can_promote_last_unit
      end
    end
  end

  describe '#perform_action' do
    subject(:game_perform) { described_class.new([white_player, black_player]) }

    context 'game has not started' do
      let(:action) { double('action', unit: double('unit', player: white_player)) }

      before do
        game_perform.instance_variable_set(:@status, :initialized)
        allow(game_perform).to receive(:unit_allowed_actions).and_return(action)
      end

      it 'raises error' do
        expect { game_perform.perform_action(action) }.to raise_error(described_class::GameNotStartedError)
      end
    end

    context 'game is already over' do
      let(:action) do
        double('action', unit: double('unit', player: white_player))
      end

      before do
        allow(action).to receive(:is_a?).with(ChessEngine::Actions::ActionCommand).and_return(true)
        game_perform.instance_variable_set(:@status, :checkmate)
        allow(game_perform).to receive(:unit_allowed_actions).and_return(action)
      end

      it 'raises error' do
        expect { game_perform.perform_action(action) }.to raise_error(described_class::GameAlreadyOverError)
      end
    end

    context 'action is not currently allowed for the unit' do
      let(:unit) { double('unit', player: white_player, location: 'b6', symbol: '♘') }
      let(:move) { double('move', unit:, location: 'h3') }
      let(:other_move) { double('move', unit:, location: 'h4') }
      let(:action) { double('action', moves: [move]) }
      let(:other_action) { double('action', moves: [other_move]) }

      before do
        allow(action).to receive(:is_a?).with(ChessEngine::Actions::ActionCommand).and_return(true)
        game_perform.instance_variable_set(:@status, :playing)
        allow(game_perform).to receive(:unit_allowed_actions).and_return([other_action])
      end

      it 'raises error' do
        expect { game_perform.perform_action(action) }.to raise_error(ArgumentError)
      end
    end

    context 'action is allowed for the unit' do
      let(:unit) { double('unit', player: white_player, location: 'b6', symbol: '♘') }
      let(:action) { double('action', moves: [double('move', unit:, location: 'h3')]) }

      before do
        allow(action).to receive(:perform_action)
        allow(action).to receive(:is_a?).with(ChessEngine::Actions::ActionCommand).and_return(true)
        game_perform.instance_variable_set(:@status, :playing)
        allow(game_perform).to receive(:unit_allowed_actions).and_return([action])
        game_perform.instance_variable_set(:@turn, 10)
        game_perform.instance_variable_set(:@current_player, white_player)
      end

      it 'sends perform_action to action and switches the player' do
        expect(action).to receive(:perform_action).once
        expect(game_perform).to receive(:switch_current_player).once
        game_perform.perform_action(action)
      end

      context 'unit can be promoted' do
        it 'does not switch players' do
          other_unit = double('other_unit', location: 'a8')
          allow(game_perform).to receive(:last_unit).and_return(other_unit)
          allow(game_perform).to receive(:can_promote_last_unit?).and_return(true)
          expect { game_perform.perform_action(action) }.not_to(change { game_perform.current_player })
        end
      end

      context 'unit cannot be promoted and not end of game' do
        it 'switches players' do
          allow(game_perform).to receive(:can_promote_last_unit?).and_return(false)
          expect { game_perform.perform_action(action) }.to change { game_perform.current_player }.to(black_player)
        end
      end

      context 'turn is over' do
        before do
          allow(game_perform).to receive(:both_players_played?).and_return(true)
        end

        it 'increments the turn' do
          game_perform.perform_action(action)
          expect(game_perform.turn).to eq(11)
        end
      end

      context 'turn is not over' do
        before do
          allow(game_perform).to receive(:both_players_played?).and_return(false)
        end

        it 'does not increment the turn' do
          game_perform.perform_action(action)
          expect(game_perform.turn).to eq(10)
        end
      end
    end
  end

  describe '#select_actionable_unit' do
    subject(:game_select) { described_class.new([white_player, black_player]) }
    let(:board_select) { ChessEngine::Board.new }
    let(:h7_pawn) { ChessEngine::Units::Pawn.new('h7', black_player) }

    before do
      board_select.add_unit(h7_pawn)
      allow(game_select).to receive(:board).and_return(board_select)
    end

    context 'unit is at location for current player' do
      before do
        allow(game_select).to receive(:current_player).and_return(black_player)
      end

      it 'unit at location is selected' do
        unit = game_select.select_actionable_unit('h7')

        expect(unit).to be(h7_pawn)
      end
    end

    context 'unit is at location but not for current player' do
      before do
        allow(game_select).to receive(:current_player).and_return(white_player)
      end

      it 'unit at location is not selected' do
        unit = game_select.select_actionable_unit('h7')

        expect(unit).to be_nil
      end
    end

    context 'unit is not at location' do
      before do
        allow(game_select).to receive(:current_player).and_return(black_player)
      end

      it 'no unit is selected' do
        unit = game_select.select_actionable_unit('a7')

        expect(unit).to be_nil
      end
    end
  end
end
