# frozen_string_literal: true

require_relative '../lib/chess-engine/board'

describe ChessEngine::Board do
  describe '#unit_at' do
    subject(:board) { described_class.new }
    let(:unit) { double('unit', location: 'g3') }

    before do
      board.add_unit(unit)
    end

    context 'a unit is at the location' do
      it 'return true' do
        result = board.unit_at('g3')
        expect(result).to be(unit)
      end
    end

    context 'a unit is not at the location' do
      it 'return true' do
        result = board.unit_at('c2')
        expect(result).to be_nil
      end
    end
  end

  describe '#unit_blocking_move?' do
    subject(:board_block) { described_class.new }

    context 'horizontal move with no other units between' do
      let(:move_unit) { double('unit', location: 'g2', color: :white) }
      let(:friendly_unit) { double('unit', location: 'c3', color: :white) }
      let(:unfriendly_unit) { double('unit', location: 'a1', color: :white) }

      before do
        board_block.add_unit(move_unit, friendly_unit, unfriendly_unit)
      end

      it 'returns false' do
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'g5')
      end
    end

    context 'horizontal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'g2', color: :white) }
      let(:friendly_unit) { double('unit', location: 'g4', color: :white) }
      let(:unfriendly_unit) { double('unit', location: 'g3', color: :black) }

      it 'returns true' do
        # check unfriendly
        board_block.add_unit(move_unit, unfriendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
        # check friendly
        board_block.clear_units.add_unit(move_unit, friendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
      end
    end
    context 'diagonal move with no units between' do
      let(:move_unit) { double('unit', location: 'b2', color: :white) }
      let(:friendly_unit) { double('unit', location: 'd5', color: :white) }
      let(:unfriendly_unit) { double('unit', location: 'e8', color: :black) }

      it 'returns false' do
        board_block.add_unit(move_unit, friendly_unit, unfriendly_unit)
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'diagonal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'b2', color: :white) }
      let(:friendly_unit) { double('unit', location: 'd4', color: :white) }
      let(:unfriendly_unit) { double('unit', location: 'f6', color: :black) }

      it 'returns true' do
        # check unfriendly
        board_block.add_unit(move_unit, unfriendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
        # check friendly
        board_block.clear_units.add_unit(move_unit, friendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
      end
    end
  end

  describe '#other_castle_unit_move' do
    subject(:board_move_hash) { described_class.new }
    let(:king) { double('king', kingside_start?: true, is_a?: ChessEngine::Units::King, location: 'e8') }
    let(:kingside_rook) { double('rook', kingside_start?: true, is_a?: ChessEngine::Units::Rook, location: 'h8') }

    it 'returns the other unit and move location' do
      allow(king).to receive(:allowed_actions_deltas).and_return({ kingside_castle: [[0, 2]] })
      allow(board_move_hash).to receive(:friendly_units).and_yield(king)
      result = board_move_hash.other_castle_unit_move(kingside_rook, :kingside_castle)
      expect(result.unit).to eq(king)
      expect(result.location).to eq('g8')
    end
  end

  describe '#units_at_file' do
    subject(:file_board) { described_class.new }

    context 'unit(s) of specified color and type are located at file' do
      let(:file_unit1) { double('unit', location: 'c8', off_board?: false, color: :black) }
      let(:file_unit2) { double('unit', location: 'c2', off_board?: false, color: :black) }

      before do
        allow(file_unit1).to receive(:instance_of?).and_return(true)
        allow(file_unit2).to receive(:instance_of?).and_return(true)
        allow(file_board).to receive(:units).and_return([file_unit1, file_unit2])
      end

      it 'returns the unit(s)' do
        result = file_board.units_at_file('c', :black, :dummy_class)
        expect(result).to contain_exactly(file_unit2, file_unit1)
      end
    end

    context 'no unit at file' do
      let(:file_unit1) { double('unit', location: 'c8', off_board?: false, color: :black) }
      let(:file_unit2) { double('unit', location: 'c2', off_board?: false, color: :black) }

      before do
        allow(file_board).to receive(:units).and_return([file_unit1, file_unit2])
      end

      it 'returns empty array' do
        result = file_board.units_at_file('d', :black, :dummy_class)
        expect(result).to match_array([])
      end
    end

    context 'unit of same color but different type on file' do
      let(:file_unit1) { double('unit', location: 'h8', off_board?: false, color: :white) }
      let(:file_unit2) { double('unit', location: 'h3', off_board?: false, color: :white) }

      before do
        allow(file_unit1).to receive(:instance_of?).and_return(false)
        allow(file_unit2).to receive(:instance_of?).and_return(true)
        allow(file_board).to receive(:units).and_return([file_unit1, file_unit2])
      end

      it 'returns only units of same type' do
        result = file_board.units_at_file('h', :white, :dummy_class_b)
        expect(result).to match_array([file_unit2])
      end
    end

    context 'unit of same type but different color on file' do
      let(:file_unit1) { double('unit', location: 'h8', off_board?: false, color: :white) }

      before do
        allow(file_board).to receive(:units).and_return([file_unit1])
        allow(file_board).to receive(:units).and_return([file_unit1])
      end

      it 'returns empty array' do
        result = file_board.units_at_file('c', :black, :dummy_class)
        expect(result).to match_array([])
      end
    end
  end

  describe '#units_at_rank' do
    subject(:rank_board) { described_class.new }

    context 'unit(s) of specified color and type are loated at rank' do
      let(:rank_unit1) { double('unit', location: 'e2', off_board?: false, color: :black) }
      let(:rank_unit2) { double('unit', location: 'c2', off_board?: false, color: :black) }

      before do
        allow(rank_unit1).to receive(:instance_of?).and_return(true)
        allow(rank_unit2).to receive(:instance_of?).and_return(true)
        allow(rank_board).to receive(:units).and_return([rank_unit1, rank_unit2])
      end

      it 'returns the unit(s)' do
        result = rank_board.units_at_rank('2', :black, :dummy_class)
        expect(result).to contain_exactly(rank_unit1, rank_unit2)
      end
    end

    context 'no unit at rank' do
      let(:rank_unit1) { double('unit', location: 'e2', off_board?: false, color: :black) }
      let(:rank_unit2) { double('unit', location: 'c2', off_board?: false, color: :black) }

      before do
        allow(rank_board).to receive(:units).and_return([rank_unit1, rank_unit2])
      end

      it 'returns empty array' do
        result = rank_board.units_at_rank('3', :black, :dummy_class)
        expect(result).to match_array([])
      end
    end

    context 'unit of same color but different type on rank' do
      let(:rank_unit1) { double('unit', location: 'b3', off_board?: false, color: :white) }
      let(:rank_unit2) { double('unit', location: 'h3', off_board?: false, color: :white) }

      before do
        allow(rank_unit1).to receive(:instance_of?).and_return(false)
        allow(rank_unit2).to receive(:instance_of?).and_return(true)
        allow(rank_board).to receive(:units).and_return([rank_unit1, rank_unit2])
      end

      it 'returns only units of same type' do
        result = rank_board.units_at_rank('3', :white, :dummy_class_b)
        expect(result).to match_array([rank_unit2])
      end
    end

    context 'unit of same type but different color on rank' do
      let(:rank_unit1) { double('unit', location: 'h8', off_board?: false, color: :white) }

      before do
        allow(rank_board).to receive(:units).and_return([rank_unit1])
        allow(rank_unit1).to receive(:class).and_return(:dummy_class)
      end

      it 'returns empty array' do
        result = rank_board.units_at_rank('8', :black, :dummy_class)
        expect(result).to match_array([])
      end
    end
  end
end
