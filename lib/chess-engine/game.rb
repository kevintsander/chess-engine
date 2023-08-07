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

    attr_reader :board, :game_log, :players, :turn, :current_player, :player_draw

    @current_player = nil
    @turn = 0
    @player_draw = false

    def initialize(players = [])
      @players = players
      @game_log = []
      @board = Board.new
      @allowed_actions_cache = {}
    end

    def add_players(players)
      @players = players
    end

    def start
      setup_new_board
      @turn = 1
      @current_player = @players.detect { |player| player.color == :white }
    end

    def game_over?
      turn&.positive? && (player_draw || fifty_turn_draw? || any_stalemate? || any_checkmate?)
    end

    def submit_draw
      @player_draw = true
    end

    def both_players_played?
      turn_logs = game_log.select { |log_item| log_item[:turn] == turn }
      player1_played = turn_logs&.select { |log_item| log_item[:action].moves[0].unit.player == players[0] }&.any?
      player2_played = turn_logs&.select { |log_item| log_item[:action].moves[0].unit.player == players[1] }&.any?
      player1_played && player2_played
    end

    def turn_over?
      both_players_played? && !can_promote_unit?(last_unit)
    end

    def perform_promote(unit, promoted_unit_class)
      promote_command = Actions::PromoteCommand.new(board, unit, unit.location, promoted_unit_class)
      perform_action(promote_command)
    end

    def perform_action(action)
      raise GameNotStartedError if turn.zero?
      raise GameAlreadyOverError if game_over?

      move = action.moves[0]
      unit = move.unit
      raise ArgumentError, 'Only current player can perform action' if unit.player != current_player

      is_promote_command = action.is_a?(Actions::PromoteCommand)
      raise MustPromoteError if last_unit && can_promote_unit?(last_unit) && !is_promote_command

      unless is_promote_command || allowed_actions(unit).include?(action)
        raise ArgumentError,
              "unit #{unit.symbol} cannot perform #{action.class.name}"
      end

      action.perform_action
      # @allowed_actions_cache = {} # reset allowed actions cache
      log_action(action)
      update_allowed_actions
      return if game_over?

      switch_current_player unless can_promote_unit?(unit)
      return unless turn_over?

      @turn += 1
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
      allowed_actions(unit).detect { |action| action.location_notation == move_location }
    end

    private

    def update_allowed_actions
      @allowed_actions_cache = {}
      # non-captured friendly units
      valid_units = board.units.select { |u| u.player == current_player && !u.captured }
      valid_units.each do |unit|
        unit_allowed_actions = allowed_actions(unit)
        @allowed_actions_cache[unit] = unit_allowed_actions if unit_allowed_actions
      end
    end

    def switch_current_player
      @current_player = other_player(current_player)
    end
  end
end
