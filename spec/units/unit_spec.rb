# frozen_string_literal: true

require_relative '../../lib/chess-engine/unit'

describe ChessEngine::Unit do
  describe '#initialize' do
    context 'white unit' do
      subject(:unit_new) { described_class.new('g2', :white) }

      it 'sets forward to positive' do
        expect(unit_new.forward).to eq(:+)
      end
    end

    context 'black unit' do
      subject(:unit_new) { described_class.new('g7', :black) }

      it 'sets forward to negative' do
        expect(unit_new.forward).to eq(:-)
      end
    end
  end

  describe '#off_board?' do
    context 'unit has no location' do
      subject(:unit_captured) { described_class.new('g5', :white) }

      it 'returns true' do
        unit_captured.instance_variable_set(:@location, nil)
        expect(unit_captured).to be_off_board
      end
    end

    context 'unit has a location' do
      subject(:unit_alive) { described_class.new('g5', :white) }
      it 'returns false' do
        expect(unit_alive).not_to be_off_board
      end
    end
  end

  describe '#capture' do
    subject(:unit_capture) { described_class.new('g5', :white) }
    it 'sets location to nil' do
      expect { unit_capture.capture }.to change { unit_capture.location }.from('g5').to(nil)
    end
  end

  describe '#move' do
    subject(:unit_move) { described_class.new('g5', :white) }

    it 'moves the location' do
      expect { unit_move.move('f7') }.to change { unit_move.location }.from('g5').to('f7')
    end
  end

  describe '#enemy?' do
    subject(:friendly_unit) { described_class.new('g5', :white) }

    context 'unit is not the same color' do
      subject(:enemy_unit) { described_class.new('g1', :black) }
      it 'returns true' do
        expect(friendly_unit).to be_enemy(enemy_unit)
      end
    end

    context 'unit is the same color' do
      subject(:friendly_unit_two) { described_class.new('g1', :white) }
      it 'returns false' do
        expect(friendly_unit).not_to be_enemy(friendly_unit_two)
      end
    end
  end
end
