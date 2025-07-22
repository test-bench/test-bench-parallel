module TestBench
  module Parallel
    module Run
      def self.call(path, exclude: nil)
        parallel_session = Session.build

        TestBench::Run.(path, exclude:, session: parallel_session)
      end
    end
  end
end
