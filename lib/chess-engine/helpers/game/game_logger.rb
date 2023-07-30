# frozen_string_literal: true

module ChessEngine
  module Helpers
    module Game
      module GameLogger
        def log_action(action)
          @game_log << { turn:, action: }
        end

        def last_action
          @game_log.last[:action] if @game_log&.any?
        end

        def last_unit
          last_action&.moves&.[](0)&.unit
        end

        def unit_actions(unit)
          @game_log.each_with_object([]) do |log_item, unit_actions|
            action = log_item[:action]
            unit_actions << action if action.moves.any? { |m| m.unit == unit }
          end
        end
      end
    end
  end
end
