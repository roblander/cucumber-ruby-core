module Cucumber
  module Core
    module Test
      class AroundStepHook
        def initialize(&block)
          @block = block
        end

        def execute(*args, &continue)
          @block.call(*args, continue)
        end
      end
    end
  end
end
