module TestBench
  class Run
    module Parallel
      def self.call(path, exclude: nil)
        Run.establish_session

        parallel_session = Session.build

        run = Run.build(exclude:, session: parallel_session)

        run.() do
          run << path

          parallel_session.wait
        end
      end
    end
  end
end
