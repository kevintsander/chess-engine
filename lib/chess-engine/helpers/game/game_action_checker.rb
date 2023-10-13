# frozen_string_literal: true

require_relative '../../actions/normal_move_command'
require_relative '../../actions/attack_move_command'
require_relative '../../actions/en_passant_command'
require_relative '../../actions/kingside_castle_command'
require_relative '../../actions/queenside_castle_command'

module ChessEngine
  module Helpers
    module Game
      module GameActionChecker
        attr_writer :test_game

        @test_game = false

        def actions_map
          { normal_move: { class: Actions::NormalMoveCommand, validator: method(:valid_standard_move_location?) },
            jump_move: { class: Actions::NormalMoveCommand, validator: method(:valid_jump_move_location?) },
            normal_attack: { class: Actions::AttackMoveCommand, validator: method(:valid_move_attack_location?) },
            jump_attack: { class: Actions::AttackMoveCommand, validator: method(:valid_jump_attack_location?) },
            initial_double: { class: Actions::NormalMoveCommand,
                              validator: method(:valid_initial_double_move_location?) },
            en_passant: { class: Actions::EnPassantCommand, validator: method(:valid_en_passant_location?) },
            queenside_castle: { class: Actions::QueensideCastleCommand, validator: method(:valid_castle_location?) },
            kingside_castle: { class: Actions::KingsideCastleCommand, validator: method(:valid_castle_location?) } }
        end

        def valid_standard_move_location?(move_action)
          move = move_action.moves[0]
          unit = move.unit
          move_location = move.location
          !board.enemy_unit_at_location?(unit,
                                         move_location) && !board.unit_blocking_move?(unit,
                                                                                      move_location)
        end

        def valid_move_attack_location?(attack_action)
          move = attack_action.moves[0]
          unit = move.unit
          move_location = move.location
          board.enemy_unit_at_location?(unit,
                                        move_location) && !board.unit_blocking_move?(unit,
                                                                                     move_location)
        end

        def valid_jump_move_location?(jump_action)
          move = jump_action.moves[0]
          move_location = move.location
          !board.unit_at(move_location)
        end

        def valid_jump_attack_location?(jump_attack_action)
          move = jump_attack_action.moves[0]
          unit = move.unit
          move_location = move.location
          board.enemy_unit_at_location?(unit, move_location)
        end

        def valid_en_passant_location?(en_passant_action)
          move = en_passant_action.moves[0]
          unit = move.unit

          return false unless unit.is_a?(ChessEngine::Units::Pawn)

          return false unless last_action

          move_location = move.location
          last_unit_location = last_unit.location
          return false unless last_unit_location

          units_delta = board.location_delta(unit.location, last_unit_location)
          last_action_move = last_action.moves[0]
          last_move_delta = board.location_delta(last_action_move.from_location, last_unit_location)
          # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
          if last_unit.is_a?(ChessEngine::Units::Pawn) &&
             units_delta[1].abs == 1 &&
             units_delta[0].abs.zero? &&
             last_move_delta[0].abs == 2 &&
             board.file(move_location) == board.file(last_unit_location)
            true
          else
            false
          end
        end

        def valid_initial_double_move_location?(double_move_action)
          move = double_move_action.moves[0]
          unit = move.unit
          move_location = move.location
          unit.is_a?(ChessEngine::Units::Pawn) &&
            !unit_actions(unit)&.any? &&
            !board.enemy_unit_at_location?(unit, move_location) &&
            !board.unit_blocking_move?(unit, move_location)
        end

        def valid_castle_location?(castle_action)
          unit_move = castle_action.moves[0]
          unit = unit_move.unit

          unit_class = unit.class
          return false unless [ChessEngine::Units::Rook, ChessEngine::Units::King].include?(unit_class)
          return false if unit_actions(unit)&.any?

          castle_type = if castle_action.is_a?(ChessEngine::Actions::KingsideCastleCommand)
                          :kingside_castle
                        elsif castle_action.is_a?(ChessEngine::Actions::QueensideCastleCommand)
                          :queenside_castle
                        end

          other_unit_allowed_move = board.other_castle_unit_move(unit, castle_type)

          move_location = unit_move.location
          other_unit_move = castle_action.moves[1]
          return false unless other_unit_move

          other_unit = other_unit_move.unit
          return false if other_unit_allowed_move != other_unit_move
          return false if unit_actions(other_unit)&.any?

          other_unit_move_location = other_unit_move.location

          # cannot be blocked or have an enemy on the move space
          return false if board.enemy_unit_at_location?(unit, move_location) ||
                          board.unit_blocking_move?(unit, move_location, other_unit)

          return false if board.enemy_unit_at_location?(other_unit, other_unit_move_location) ||
                          board.unit_blocking_move?(other_unit, other_unit_move_location, unit)

          # neither unit can have moved
          return false if [unit, other_unit].any? { |castle_unit| unit_actions(castle_unit)&.any? }

          # king cannot pass over space that could be attacked
          king = unit_class == ChessEngine::Units::King ? unit : other_unit
          king_move_location = unit_class == ChessEngine::Units::King ? move_location : other_unit_move_location
          return false if board.enemy_can_attack_move?(king, king_move_location)

          true
        end

        def allowed_actions(unit)
          allowed_actions_cached = @allowed_actions_cache[unit.location] #check if there is an action already cached
          unless allowed_actions_cached
            allowed = []
            return allowed unless unit.location

            unit.allowed_actions_deltas.each do |(action_type, deltas)|
              action_map = actions_map[action_type]
              deltas.each do |delta|
                move_location = board.delta_location(unit.location, delta)
                next unless move_location

                action_class = action_map[:class]
                action = action_class.new(board, unit, move_location)

                next unless action_map[:validator].call(action)
                next if action_would_cause_check?(action)

                allowed << action
              end
            end
            @allowed_actions_cache[unit.location] = allowed
          end
          @allowed_actions_cache[unit.location]
        end

        def units_with_actions(player)
          board.units.select do |unit|
            allowed_actions = allowed_actions(unit)
            unit.player == player && allowed_actions && allowed_actions.any?
          end
        end

        def action_would_cause_check?(action)
          if @test_game
            return false
          end # for test game, do not perform this check because we need to test if moves would cause check

          # create a test game
          new_test_game = get_test_game_copy
          new_test_game_units = new_test_game.board.units
          move = action.moves[0]
          test_unit = new_test_game_units.detect { |unit| unit.location == move.from_location }
          test_friendly_king = new_test_game_units.detect do |unit|
            unit.is_a?(ChessEngine::Units::King) && unit.player == move.unit.player
          end

          # get a copy of the action to test
          test_action = action.class.new(new_test_game.board, test_unit, move.location)

          test_action.perform_action

          new_test_game.check?(test_friendly_king)
        end

        def can_promote_unit?(unit)
          return false unless (unit_location = unit.location)
          return false unless unit.is_a?(ChessEngine::Units::Pawn)

          forward_delta = [0.send(unit.forward, 1), 0]
          test_forward_location = board.delta_location(unit_location, forward_delta)

          test_forward_location ? false : true
        end

        private

        # creates a test game
        def get_test_game_copy
          test = self.class.new(players)
          test.test_game = true
          test_board_units = board.units.map { |unit| unit.dup }
          test_game_log = game_log.map { |log_item| log_item[:action].dup }
          test.instance_variable_set(:@game_log, test_game_log)
          test.board.clear_units.add_unit(*test_board_units)
          test
        end
      end
    end
  end
end
