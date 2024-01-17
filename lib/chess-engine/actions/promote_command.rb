# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    class PromoteCommand
      attr_reader :unit, :promoted_unit_class

      def initialize(board, unit, promoted_unit_class)
        @unit = unit
        @board = board
        @promoted_unit_class = promoted_unit_class
      end

      def perform_action(board)
        location = unit.location
        promoted_unit = @promoted_unit_class.new(location, unit.color)

        unit.promote
        board.add_unit(promoted_unit)
      end

      def ==(other)
        other.unit == unit && other.promoted_unit_class = promoted_unit_class
        other.moves.difference(moves).none? && other.location_notation == location_notation && other.capture_unit == capture_unit
      end
    end
  end
end
