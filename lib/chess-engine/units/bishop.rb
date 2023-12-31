# frozen_string_literal: true

require_relative '../unit'

# Represents a King chess piece
module ChessEngine
  module Units
    class Bishop < Unit
      def allowed_actions_deltas
        @allowed_actions_deltas ||= { normal_move: bishop_deltas,
                                      normal_attack: bishop_deltas }
        @allowed_actions_deltas
      end

      private

      def bishop_deltas
        (1..7).reduce([]) { |all, dist| all + [[dist, dist], [dist, -dist], [-dist, dist], [-dist, -dist]] }
      end
    end
  end
end
