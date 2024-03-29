# frozen_string_literal: true

require_relative '../unit'

# Represents a King chess piece
module ChessEngine
  module Units
    class Rook < Unit
      def initialize(location, color, id = location)
        super(location, color, id)
        @allowed_actions_deltas = { normal_move: rook_deltas,
                                    normal_attack: rook_deltas }
        @allowed_actions_deltas[:kingside_castle] = kingside_castle_delta if kingside_start?
        @allowed_actions_deltas[:queenside_castle] = queenside_castle_delta if queenside_start?
      end

      def allowed_actions_deltas
        @allowed_actions_deltas ||= { normal_move: rook_deltas,
                                      normal_attack: rook_deltas }
        @allowed_actions_deltas[:kingside_castle] ||= kingside_castle_delta if kingside_start?
        @allowed_actions_deltas[:queenside_castle] ||= queenside_castle_delta if queenside_start?
        @allowed_actions_deltas
      end

      private

      def rook_deltas
        (1..7).reduce([]) { |all, dist| all + [[0, dist], [0, -dist], [dist, 0], [-dist, 0]] }
      end

      def kingside_castle_delta
        [[0, -2]]
      end

      def queenside_castle_delta
        [[0, 3]]
      end
    end
  end
end
