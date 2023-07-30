# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an attack move that will capture another unit
    class AttackMoveCommand < ActionCommand
      DISPLAY_NAME = 'Attack move'

      def initialize(board, unit, location)
        super(board, unit, location)
        initialize_capture_unit(board)
      end

      private

      def initialize_capture_unit(board)
        move = moves[0]
        location = move.location
        @capture_unit = board.unit_at(location)
      end
    end
  end
end
