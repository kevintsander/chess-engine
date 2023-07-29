# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents an attack move that will capture another unit
    class AttackMoveCommand < ActionCommand
      DISPLAY_NAME = 'Attack move'

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
        @captured_unit = board.unit_at(location)
      end
    end
  end
end
