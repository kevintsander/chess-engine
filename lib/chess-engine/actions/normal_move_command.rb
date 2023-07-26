# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents a normal move
    class NormalMoveCommand < ActionCommand
      DISPLAY_NAME = 'Normal move'

      def perform_moves
        unit.move(location)
        # game_log.log_action(turn, :move, unit, location, last_location)
      end
    end
  end
end
