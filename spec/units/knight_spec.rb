# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/knight'

describe ChessEngine::Units::Knight do
  describe '#initialize' do
    context 'player color is black' do
      subject(:black_knight) { described_class.new('g8', :black) }

      it 'sets symbol to black knight' do
        expect(black_knight.symbol).to eq('♞')
      end
    end

    context 'player color is white' do
      subject(:white_knight) { described_class.new('g1', :white) }

      it 'sets symbol to white knight' do
        expect(white_knight.symbol).to eq('♘')
      end
    end
  end
end
