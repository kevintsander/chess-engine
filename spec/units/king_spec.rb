# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/king'

describe ChessEngine::Units::King do
  describe '#initialize' do
    context 'player color is black' do
      subject(:black_king) { described_class.new('e8', :black) }

      it 'sets symbol to black king' do
        expect(black_king.symbol).to eq('♚')
      end
    end

    context 'player color is white' do
      subject(:white_king) { described_class.new('e1', :white) }

      it 'sets symbol to white king' do
        expect(white_king.symbol).to eq('♔')
      end
    end
  end
end
