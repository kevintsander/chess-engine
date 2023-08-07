# frozen_string_literal: true

require_relative './helpers/location_rank_and_file'
require_relative './helpers/board/board_location_mapper'
require_relative './helpers/board/board_status_checker'
require_relative './units/king'
require_relative './units/queen'
require_relative './units/bishop'
require_relative './units/knight'
require_relative './units/rook'
require_relative './units/pawn'
require_relative './actions/unit_move'

# Represents a chess board
module ChessEngine
  class Board
    include Helpers::LocationRankAndFile
    include Helpers::Board::BoardLocationMapper
    include Helpers::Board::BoardStatusChecker

    attr_reader :units

    def initialize
      clear_units
    end

    def clear_units
      @units = []
      self
    end

    def add_unit(*args)
      args.each do |unit|
        @units << unit
      end
      self
    end

    def unit_at(location, delta = nil)
      at_location = delta ? delta_location(location, delta) : location
      units.select { |unit| unit.location == at_location }&.first
    end

    def units_at_file(file, color, unit_class)
      units.select do |unit|
        !unit.off_board? &&
          file(unit.location) == file &&
          unit.player.color == color &&
          unit.instance_of?(unit_class)
      end
    end

    def units_at_rank(rank, color, unit_class)
      units.select do |unit|
        !unit.off_board? &&
          rank(unit.location) == rank &&
          unit.player.color == color &&
          unit.instance_of?(unit_class)
      end
    end

    def friendly_units(unit)
      if block_given?
        units.each do |other|
          yield(other) if unit.friendly?(other)
        end
      else
        units.select { |other| unit.friendly?(other) }
      end
    end

    def enemy_units(unit)
      if block_given?
        units.each do |other|
          yield(other) if unit.enemy?(other)
        end
      else
        units.select { |other| unit.enemy?(other) }
      end
    end

    def other_castle_unit_move(unit, castle_type)
      friendly_units(unit) do |friendly|
        if castle_type == :kingside_castle && !friendly.is_a?(ChessEngine::Units::King) && !friendly.kingside_start?
          next
        end
        if castle_type == :queenside_castle && !friendly.is_a?(ChessEngine::Units::King) && !friendly.queenside_start?
          next
        end
        next unless friendly.location

        delta = friendly.allowed_actions_deltas[castle_type]&.first
        next unless delta

        return Actions::UnitMove.new(friendly, delta_location(friendly.location, delta))
      end
      nil
    end
  end
end
