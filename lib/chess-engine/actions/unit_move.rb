# frozen_string_literal: true

module ChessEngine
  module Actions
    class UnitMove
      attr_reader :unit, :location, :from_location

      def initialize(unit, location)
        @unit = unit
        @location = location
        @from_location = unit.location
      end
    end
  end
end
