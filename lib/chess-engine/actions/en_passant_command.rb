# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an en passant move
    class EnPassantCommand < ActionCommand
      DISPLAY_NAME = 'En passant'

      def perform_moves
        captured_unit = board.unit_at(location, [-1 * 0.send(unit.forward, 1), 0])
        unit.move(location)
        captured_unit.capture
        @captured_unit = captured_unit
      end
    end
  end
end
