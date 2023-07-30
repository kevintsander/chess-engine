# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents a queenside castle move
    class QueensideCastleCommand < ActionCommand
      DISPLAY_NAME = 'Queenside castle'

      def initialize(board, unit, location)
        super(board, unit, location)
        @location_notation = 'O-O-O'
        initialize_other_unit_move(board)
      end

      private

      def initialize_other_unit_move(board)
        unit = moves[0].unit
        moves.push(board.other_castle_unit_move(unit, :queenside_castle))
      end
    end
  end
end
