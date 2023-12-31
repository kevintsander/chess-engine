# frozen_string_literal: true

require_relative '../../lib/chess-engine/units/bishop'

describe ChessEngine::Units::Bishop do
  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_bishop) { described_class.new('c8', black_player) }

      it 'sets symbol to black bishop' do
        expect(black_bishop.symbol).to eq('♝')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_bishop) { described_class.new('c1', white_player) }

      it 'sets symbol to white bishop' do
        expect(white_bishop.symbol).to eq('♗')
      end
    end
  end
end
