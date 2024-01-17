# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/bishop'

describe ChessEngine::Units::Bishop do
  describe '#initialize' do
    context 'color is black' do
      subject(:black_bishop) { described_class.new('c8', :black) }

      it 'sets symbol to black bishop' do
        expect(black_bishop.symbol).to eq('♝')
      end
    end

    context 'color is white' do
      subject(:white_bishop) { described_class.new('c1', :white) }

      it 'sets symbol to white bishop' do
        expect(white_bishop.symbol).to eq('♗')
      end
    end
  end
end
