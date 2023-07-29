# frozen_string_literal: true

# Represents a chess move
module ChessEngine
  class ActionCommand
    attr_reader :unit, :location, :action, :captured_unit

    def initialize(board, unit, location)
      @board = board
      @unit = unit
      @location = location
      @from_location = nil
      @captured_unit = nil
    end

    def ==(other)
      other.class == self.class && other.board == board && other.unit == unit && other.location == location
    end

    def location_notation
      location
    end

    def perform_action
      @from_location = unit.location
      perform_moves
    end

    private

    attr_reader :board, :from_location
  end
end
