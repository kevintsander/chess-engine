# frozen_string_literal: true

require_relative '../unit'

# Represents a King chess piece
module ChessEngine
  module Units
    class Knight < Unit
      def allowed_actions_deltas
        @allowed_actions_deltas ||= { jump_move: knight_deltas,
                                      jump_attack: knight_deltas }
        @allowed_actions_deltas
      end

      private

      def knight_deltas
        [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
      end
    end
  end
end
