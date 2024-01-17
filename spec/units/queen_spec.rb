# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/queen'

describe ChessEngine::Units::Queen do
  describe '#initialize' do
    context 'player color is black' do
      subject(:black_queen) { described_class.new('d8', :black) }

      it 'sets symbol to black queen' do
        expect(black_queen.symbol).to eq('♛')
      end
    end

    context 'player color is white' do
      subject(:white_queen) { described_class.new('d1', :white) }

      it 'sets symbol to white queen' do
        expect(white_queen.symbol).to eq('♕')
      end
    end
  end
end
