# frozen_string_literal: true

module ChessEngine
  module Helpers
    module Game
      module GameStatusChecker
        def check?(king)
          king.is_a?(ChessEngine::Units::King) && board.enemy_can_attack_location?(king, king.location)
        end

        def checkmate?(king)
          return unless king.is_a?(ChessEngine::Units::King)
          return unless check?(king)
          return if friendly_units_have_moves(king)
          return if unit_allowed_actions(king).any?

          true
        end

        def friendly_units_have_moves(unit)
          board.friendly_units(unit).any? do |friendly|
            unit_allowed_actions = unit_allowed_actions(friendly)
            unit_allowed_actions&.any?
          end
        end

        def any_check?
          board.units.any? { |unit| unit.is_a?(ChessEngine::Units::King) && check?(unit) }
        end

        def any_checkmate?
          board.units.any? { |unit| unit.is_a?(ChessEngine::Units::King) && checkmate?(unit) }
        end

        def stalemate?(king)
          king.is_a?(ChessEngine::Units::King) && !check?(king) && !friendly_units_have_moves(king) && unit_allowed_actions(king).none?
        end

        def any_stalemate?
          board.units.any? { |unit| unit.is_a?(ChessEngine::Units::King) && stalemate?(unit) }
        end

        def fifty_turn_draw?
          turn > 50
        end
      end
    end
  end
end
