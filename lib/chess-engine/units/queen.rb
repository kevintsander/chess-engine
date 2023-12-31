# frozen_string_literal: true

require_relative '../unit'

# Represents a King chess piece
module ChessEngine
  module Units
    class Queen < Unit
      def allowed_actions_deltas
        @allowed_actions_deltas ||= { normal_move: queen_deltas,
                                      normal_attack: queen_deltas }
        @allowed_actions_deltas
      end

      private

      def queen_deltas
        straight = (1..7).reduce([]) { |all, dist| all + [[dist, 0], [-dist, 0], [0, dist], [0, -dist]] }
        diagonal = (1..7).reduce([]) { |all, dist| all + [[dist, dist], [dist, -dist], [-dist, dist], [-dist, -dist]] }
        straight + diagonal
      end
    end
  end
end
