# frozen_string_literal: true

require_relative './actions/unit_move'

# Represents a chess move
module ChessEngine
  class ActionCommand
    attr_reader :moves, :capture_unit, :location_notation

    def initialize(_board, unit, location)
      @moves = [Actions::UnitMove.new(unit, location)]
      @location_notation = location
      @capture_unit = nil
    end

    def perform_action
      moves.each do |move|
        move.unit.move(move.location)
      end
      capture_unit&.capture
    end
  end
end
