# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/rook'

describe ChessEngine::Units::Rook do
  describe '#initialize' do
    context 'color is black' do
      subject(:black_rook) { described_class.new('a8', :black) }

      it 'sets symbol to black rook' do
        expect(black_rook.symbol).to eq('♜')
      end
    end

    context 'color is white' do
      subject(:white_rook) { described_class.new('a1', :white) }

      it 'sets symbol to white rook' do
        expect(white_rook.symbol).to eq('♖')
      end
    end
  end
end
