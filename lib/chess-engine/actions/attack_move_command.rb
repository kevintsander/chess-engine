# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an attack move that will capture another unit
    class AttackMoveCommand < ActionCommand
      DISPLAY_NAME = 'Attack move'

      def perform_moves
        captured_unit = board.unit_at(location)
        unit.move(location)
        captured_unit.capture
        @captured_unit = captured_unit
      end
    end
  end
end
