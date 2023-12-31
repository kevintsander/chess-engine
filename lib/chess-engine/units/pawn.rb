# frozen_string_literal: true

require_relative '../unit'

# Represents a King chess piece
module ChessEngine
  module Units
    class Pawn < Unit
      def allowed_actions_deltas
        @allowed_actions_deltas ||= { normal_move: pawn_move_delta,
                                      initial_double: pawn_double_delta,
                                      normal_attack: pawn_attack_deltas,
                                      en_passant: pawn_attack_deltas }
        @allowed_actions_deltas
      end

      private

      def forward_rank_dir
        0.send(forward, 1)
      end

      def pawn_move_delta
        [[forward_rank_dir, 0]]
      end

      def pawn_double_delta
        [[forward_rank_dir * 2, 0]]
      end

      def pawn_attack_deltas
        [[forward_rank_dir, -1], [forward_rank_dir, 1]]
      end
    end
  end
end
