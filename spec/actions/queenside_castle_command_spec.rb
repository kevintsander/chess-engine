# frozen_string_literal: true

require_relative '../../lib/chess-engine/actions/queenside_castle_command'

describe ChessEngine::Actions::QueensideCastleCommand do
  let(:board) { double('board') }
  let(:queenside_rook) { double('queenside_rook', location: 'h1') }
  let(:other_unit_move) { double('queenside_rook_move', unit: queenside_rook, location: 'd1') }
  let(:king) { double('king', location: 'd1') }
  subject(:queenside_castle) { described_class.new(board, king, 'c1') }

  describe '#perform_action' do
    it 'moves the unit and captures one on the same space' do
      allow(board).to receive(:other_castle_unit_move).and_return(other_unit_move)
      allow(king).to receive(:move).with('c1')
      allow(queenside_rook).to receive(:move).with('d1')
      expect(king).to receive(:move).with('c1').once
      expect(queenside_rook).to receive(:move).with('d1').once
      queenside_castle.perform_action
    end
  end
end
