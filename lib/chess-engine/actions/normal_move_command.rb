# frozen_string_literal: true

require_relative '../action_command'

module ChessEngine
  module Actions
    # represents a normal move
    class NormalMoveCommand < ActionCommand
      DISPLAY_NAME = 'Normal move'
    end
  end
end
