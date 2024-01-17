# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/pawn'

describe ChessEngine::Units::Pawn do
  context 'black pawn' do
    subject(:pawn_seven) { described_class.new('g7', :black) }
    it 'can only attack or move to lower rank' do
      move_ranks = pawn_seven.allowed_actions_deltas[:normal_move].map { |item| item[0] }
      attack_ranks = pawn_seven.allowed_actions_deltas[:normal_attack].map { |item| item[0] }
      en_passant_ranks = pawn_seven.allowed_actions_deltas[:en_passant].map { |item| item[0] }
      expect(move_ranks).to include(-1)
      expect(move_ranks).not_to include(1)
      expect(attack_ranks).to include(-1)
      expect(attack_ranks).not_to include(1)
      expect(en_passant_ranks).to include(-1)
      expect(en_passant_ranks).not_to include(1)
    end
  end

  context 'white pawn' do
    subject(:pawn_two) { described_class.new('g2', :white) }
    it 'can only attack or move to higher rank' do
      move_ranks = pawn_two.allowed_actions_deltas[:normal_move].map { |item| item[0] }
      attack_ranks = pawn_two.allowed_actions_deltas[:normal_attack].map { |item| item[0] }
      en_passant_ranks = pawn_two.allowed_actions_deltas[:en_passant].map { |item| item[0] }
      expect(move_ranks).to include(1)
      expect(move_ranks).not_to include(-1)
      expect(attack_ranks).to include(1)
      expect(attack_ranks).not_to include(-1)
      expect(en_passant_ranks).to include(1)
      expect(en_passant_ranks).not_to include(-1)
    end
  end

  describe '#initialize' do
    context 'player color is black' do
      subject(:black_pawn) { described_class.new('a2', :black) }

      it 'sets symbol to black pawn' do
        expect(black_pawn.symbol).to eq('♟')
      end
    end

    context 'player color is white' do
      subject(:white_pawn) { described_class.new('a2', :white) }

      it 'sets symbol to white pawn' do
        expect(white_pawn.symbol).to eq('♙')
      end
    end
  end
end
