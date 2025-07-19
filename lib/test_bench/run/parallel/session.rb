module TestBench
  class Run
    module Parallel
      class Session
        attr_reader :session
        attr_reader :processes

        attr_accessor :threads
        attr_accessor :file_path_queue
        attr_accessor :telemetry_queue

        def initialize(session, processes)
          @session = session
          @processes = processes
        end

        def self.build(processes: nil)
          processes ||= Defaults.processes

          session = self.establish_session

          new(session, processes)
        end

        def self.establish_session
          Run.establish_session
        end

        def register_telemetry_sink(...)
          session.register_telemetry_sink(...)
        end

        def result(...)
          session.result(...)
        end

        def execute(file_path)
          start if not started?

          file_path_queue.push(file_path)
        end

        def wait
          file_path_queue.close

          until threads.empty?
            while event_data_batch = telemetry_queue.pop(timeout: 0)
              event_data_batch.each do |event_data|
                session.record_event(event_data)
              end

              ## If abort on failure only
              case session.result
              when TestBench::Session::Result.aborted, TestBench::Session::Result.failed
                file_path_queue.clear
                threads.map(&:join)
                telemetry_queue.clear
              end
            end

            threads.delete_if do |thread|
              !thread.alive?
            end
          end
        end

        def started?
          !threads.nil?
        end

        def start
          self.file_path_queue = Queue.new
          self.telemetry_queue = Queue.new

          self.threads = processes.times.map do |process|
            Thread.new do
              session = TestBench::Session.build

              telemetry_sink = TelemetrySink.new(telemetry_queue)
              session.register_telemetry_sink(telemetry_sink)

              while file_path = file_path_queue.pop
                session.execute(file_path)

                telemetry_sink.flush
              end
            end
          end
        end

        class TelemetrySink
          include Telemetry::Sink

          def event_data_batch
            @event_data_batch ||= []
          end
          attr_writer :event_data_batch

          attr_reader :queue

          def initialize(queue)
            @queue = queue
          end

          def receive(event_data)
            event_data_batch.push(event_data)
          end

          def flush
            queue.push(event_data_batch)

            self.event_data_batch = nil
          end
        end

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
end
