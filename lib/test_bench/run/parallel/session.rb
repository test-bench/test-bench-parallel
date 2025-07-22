module TestBench
  class Run
    module Parallel
      class Session
        attr_reader :session
        attr_reader :processes

        attr_accessor :threads
        attr_accessor :file_path_queue
        attr_accessor :telemetry_queue

        def pending_file_count
          @pending_file_count ||= 0
        end
        attr_writer :pending_file_count

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

          self.pending_file_count += 1

          file_path_queue.push(file_path)

          until pending_file_count <= threads.count
            update
          end
        end

        def close
          file_path_queue.close

          until threads.empty?
            update

            threads.delete_if do |thread|
              !thread.alive?
            end
          end
        end

        def update
          timeout_milliseconds = 100
          timeout_seconds = Rational(timeout_milliseconds, 1_000)

          while event_data_batch = telemetry_queue.pop(timeout: timeout_seconds)
            event_data_batch.each do |event_data|
              session.record_event(event_data)

              case event_data
              when TestBench::Session::Events::FileExecuted
                self.pending_file_count -= 1
              end
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
      end
    end
  end
end
