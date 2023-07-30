# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an en passant move
    class EnPassantCommand < ActionCommand
      DISPLAY_NAME = 'En passant'

      def initialize(board, unit, location)
        super(board, unit, location)
        initialize_capture_unit(board)
      end

      def perform_moves
        unit.move(location)
        @capture_unit.capture
      end

      private

      def initialize_capture_unit(board)
        move = moves[0]
        unit = move.unit
        location = move.location
        @capture_unit = board.unit_at(location, [-1 * 0.send(unit.forward, 1), 0])
      end
    end
  end
end
