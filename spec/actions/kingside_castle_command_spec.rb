# frozen_string_literal: true

require_relative '../../lib/chess-engine/actions/kingside_castle_command'

describe ChessEngine::Actions::KingsideCastleCommand do
  let(:board) { double('board') }
  let(:kingside_rook) { double('kingside_rook', location: 'h8') }
  let(:other_unit_move) { double('kingside_rook_move', unit: kingside_rook, location: 'f8') }
  let(:king) { double('king', location: 'e8') }
  subject(:kingside_castle) { described_class.new(board, king, 'g8') }

  describe '#perform_action' do
    it 'moves the unit and captures one on the same space' do
      allow(board).to receive(:other_castle_unit_move).and_return(other_unit_move)
      allow(king).to receive(:move).with('g8')
      allow(kingside_rook).to receive(:move).with('f8')
      expect(king).to receive(:move).with('g8').once
      expect(kingside_rook).to receive(:move).with('f8').once
      kingside_castle.perform_action
    end
  end
end
