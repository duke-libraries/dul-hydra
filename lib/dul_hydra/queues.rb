module DulHydra
  #
  # DulHydra::Queues - Encapsulates various queue management operations.
  #
  class Queues

    class << self
      def start
        stopped? && system("resque-pool -d -E #{Rails.env}")
      end

      def stopped?
        !running?
      end

      def stop
        interrupt("QUIT")
      end

      def restart
        if stop
          while running?
            sleep 1
          end
          start
        else
          false
        end
      end

      def reload
        interrupt("HUP")
      end

      def running?
        system("pgrep -f resque-pool")
      end

      def interrupt(signal)
        running? && system("pkill -#{signal} -f resque-pool")
      end
    end

  end
end
