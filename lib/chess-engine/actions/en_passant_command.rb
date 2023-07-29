# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an en passant move
    class EnPassantCommand < ActionCommand
      DISPLAY_NAME = 'En passant'

      def initialize(board, unit, location)
        super(board, unit, location)
        set_captured_unit
      end

      def perform_moves
        unit.move(location)
        @captured_unit.capture
      end

      private

      def set_captured_unit
        @captured_unit = board.unit_at(location, [-1 * 0.send(unit.forward, 1), 0])
      end
    end
  end
end
