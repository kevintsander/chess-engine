module ChessEngine
  module Errors
    module GameErrors
      # Error to be raised when game is already over
      class GameAlreadyOverError < RuntimeError
        def initialize(msg = 'game already over')
          super
        end
      end

      # Error to be raise when the game is not started
      class GameNotStartedError < RuntimeError
        def initialize(msg = 'game not started')
          super
        end
      end

      # Error to be raised when a unit must be promoted before taking an action
      class MustPromoteError < RuntimeError
        def initialize(msg = 'must promote unit to perform this action')
          super
        end
      end

      # Error to be raised if a promote action was received when it is not possible
      class MustPerformActionError < RuntimeError
        def initialize(msg = 'must perform a promotion before another action can be performed')
          super
        end
      end
    end
  end
end
