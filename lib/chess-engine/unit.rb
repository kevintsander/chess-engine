# frozen_string_literal: true

require_relative './helpers/unit/unit_symbol_mapper'
require_relative './helpers/location_rank_and_file'

# Represents an abstract chess unit
module ChessEngine
  class Unit
    include Helpers::Unit::UnitSymbolMapper
    include Helpers::LocationRankAndFile

    attr_reader :location, :color, :id, :symbol, :captured, :promoted, :initial_location

    def initialize(location, color, id = location)
      @location = location
      @color = color
      @id = id
      @symbol = get_color_symbol(color)
      @initial_location = location
      @captured = false
      @promoted = false
      @allowed_actions_deltas = nil
    end

    def name
      self.class.name.split('::').last
    end

    def off_board?
      !location
    end

    def capture
      @location = nil
      @captured = true
    end

    def promote
      @location = nil
      @promoted = true
    end

    def move(location)
      @location = location
    end

    def enemy?(other_unit)
      other_unit && color != other_unit.color
    end

    def friendly?(other_unit)
      other_unit && self != other_unit && color == other_unit.color
    end

    def queenside_start?
      %w[a b c d].include?(@initial_location[0])
    end

    def kingside_start?
      %w[e f g h].include?(@initial_location[0])
    end

    # Gets forward location based on initial location, to be used by constructor
    def forward
      case color
      when :white
        :+
      when :black
        :-
      end
    end

    def encode_with(coder)
      coder['location'] = location
      coder['color'] = color
      coder['id'] = id
      coder['symbol'] = symbol
      coder['initial_location'] = @initial_location
      coder['captured'] = captured
      coder['promoted'] = promoted
    end
  end
end
