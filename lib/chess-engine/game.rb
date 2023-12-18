# frozen_string_literal: true

require_relative './board'
require_relative './helpers/game/game_logger'
require_relative './helpers/game/game_action_checker'
require_relative './helpers/game/game_status_checker'
require_relative './errors/game_errors'
require_relative './actions/promote_command'

# Represents a Chess game
module ChessEngine
  class Game
    include Errors::GameErrors
    include Helpers::Game::GameLogger
    include Helpers::Game::GameActionChecker
    include Helpers::Game::GameStatusChecker

    attr_reader :board, :game_log, :players, :turn, :current_player, :allowed_actions, :promote_location, :status

    @current_player = nil
    @turn = 0
    @player_draw = false

    def initialize(players = [])
      @players = players
      @game_log = []
      @board = Board.new
      @allowed_actions = {}
      @promote_location = nil
      @status = :initialized
    end

    def add_players(players)
      @players = players
    end

    def start
      setup_new_board
      @turn = 1
      @current_player = @players.detect { |player| player.color == :white }
      @status = :playing
      set_allowed_actions
    end

    def submit_draw
      return unless %i[playing check].include?(status)

      @status = :player_draw
    end

    def both_players_played?
      turn_logs = game_log.select { |log_item| log_item[:turn] == turn }
      player1_played = turn_logs&.select { |log_item| log_item[:action].moves[0].unit.player == players[0] }&.any?
      player2_played = turn_logs&.select { |log_item| log_item[:action].moves[0].unit.player == players[1] }&.any?
      player1_played && player2_played
    end

    def perform_action(action)
      case @status
      when :initialized
        raise GameNotStartedError
      when :playing, :check
        raise MustPerformActionError unless action.is_a?(Actions::ActionCommand)

        unit = action.moves[0].unit
        unless unit_allowed_actions(unit).include?(action)
          raise ArgumentError,
                "unit #{unit.symbol} cannot perform #{action.class.name}"
        end

        action.perform_action
        log_action(action)

        # set next state
        @status = if any_check?
                    :check
                  elsif can_promote_last_unit?
                    :promoting
                  elsif fifty_turn_draw?
                    :max_turn_draw
                  elsif any_stalemate?
                    :stalemate
                  elsif any_checkmate?
                    :checkmate
                  else
                    :playing
                  end

        if %i[playing check].include?(@status)
          @turn += 1 if both_players_played?
          switch_current_player
        end
        set_allowed_actions
        set_promote_location

      when :promoting
        raise MustPromoteError unless action.is_a?(Actions::PromoteCommand)

        action.perform_action(board)
        # log_action(action)

        # set next state
        @status = if any_check?
                    :check
                  elsif fifty_turn_draw?
                    :max_turn_draw
                  elsif any_stalemate?
                    :stalemate
                  elsif any_checkmate?
                    :checkmate
                  else
                    :playing
                  end

        if %i[playing check].include?(@status)
          @turn += 1 if both_players_played?
          switch_current_player
        end
        set_allowed_actions
        set_promote_location

      when :checkmate, :stalemate, :player_draw, :max_turn_draw
        raise GameAlreadyOverError
      end
    end

    def game_over?
      %i[player_draw max_turn_draw stalemate checkmate].include?(status)
    end

    def set_allowed_actions
      @allowed_actions = {}
      return unless %i[playing check].include?(status)

      board.units.select { |u| u.player == current_player }.select(&:location).each do |unit|
        @allowed_actions[unit.location] = unit_allowed_actions(unit)
      end
    end

    def set_promote_location
      @promote_location = nil
      return unless status == :promoting

      @promote_location = last_unit.location
    end

    def new_game_units
      units = []
      players.each do |player|
        non_pawn_rank = player.color == :white ? '1' : '8'
        pawn_rank = player.color == :white ? '2' : '7'
        units << Units::King.new("e#{non_pawn_rank}", player)
        units << Units::Queen.new("d#{non_pawn_rank}", player)
        units += %w[c f].map { |file| Units::Bishop.new("#{file}#{non_pawn_rank}", player) }
        units += %w[b g].map { |file| Units::Knight.new("#{file}#{non_pawn_rank}", player) }
        units += %w[a h].map { |file| Units::Rook.new("#{file}#{non_pawn_rank}", player) }
        units += %w[a b c d e f g h].map { |file| Units::Pawn.new("#{file}#{pawn_rank}", player) }
      end
      units
    end

    def setup_new_board
      @board.clear_units.add_unit(*new_game_units)
    end

    def other_player(player)
      (players - [player]).first
    end

    def select_actionable_unit(location)
      unit_at_location = board.unit_at(location)
      if unit_at_location&.player == current_player && units_with_actions(current_player).include?(unit_at_location)
        unit = unit_at_location
      end
      unit
    end

    def select_allowed_action(unit, move_location)
      unit_allowed_actions(unit).detect { |action| action.location_notation == move_location }
    end

    def select_promote_action(promoted_unit_class)
      Actions::PromoteCommand.new(board, last_unit, promoted_unit_class)
    end

    private

    def switch_current_player
      @current_player = other_player(current_player)
    end
  end
end
