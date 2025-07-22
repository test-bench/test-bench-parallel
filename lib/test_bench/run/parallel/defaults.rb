module TestBench
  class Run
    module Parallel
      module Defaults
        def self.processes
          env_processes = ENV['TEST_BENCH_PARALLEL_PROCESSES']

          if not env_processes.nil?
            env_processes.to_i
          else
            Etc.nprocessors
          end
        end
      end
    end
  end
end
