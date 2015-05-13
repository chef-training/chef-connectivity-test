module Training

  # A utility class for creating a "check", such as networking
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Checker
    # Helper method for silencing stdout
    def silence(&block)
      old = $stdout.dup
      $stdout.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
      $stdout.sync = true
      yield
    ensure
      $stdout.reopen(old)
    end

    class << self
      # Execute each method, in order, with response handling and checking
      def run!
        @_pre.call if @_pre.respond_to?(:call)

        _checks.each do |key, check|
          run_check(check)
        end

        @_post.call if @_post.respond_to?(:call)
      end

      # Block to execute before all checks are run (setup)
      def pre(&block)
        @_pre = block
      end

      # Block to execute after all checks are run (cleanup)
      def post(&block)
        @_post = block
      end

      # Banner text to display when executing a check; if no parameter
      # is given, the banner is returned - otherwise it is set to `text`
      #
      # @raise [ArgumentError]
      #   if there is no banner set
      #
      # @param [String, nil] text
      #   the text to set the banner
      #
      # @return [String]
      #   the banner
      def banner(text = nil)
        if text.nil?
          @banner || raise(ArgumentError, "No banner given at #{caller[1]}")
        else
          @banner = text
        end
      end

      # The success message (default is 'OK')
      #
      # @see {banner} for usage
      def success_message(text = nil)
        text.nil? ? @success_message ||= 'OK' : @success_message = text
      end

      # The failure message (default is 'FAIL')
      #
      # @see {banner} for usage
      def failure_message(text = nil)
        text.nil? ? @failure_message ||= 'FAIL!' : @failure_message = text
      end

      # Special Ruby method that is fired whenever a new method is added;
      # since classes will inherit from the parent class, this is called
      # as the class is read.
      def method_added(check)
        return unless public_method_defined?(check)

        _checks[check] = Training::Check.new(
          check,
          banner,
          success_message,
          failure_message,
        )

        @banner = nil
        @success_message = nil
        @failure_message = nil
      end

      private
        def _checks
          @_checks ||= {}
        end

        def _instance
          @_instance ||= self.new
        end

        def run_check(check)
          print check.banner + '... '

          result = Timeout::timeout(TIMEOUT) do
            _instance.send(check.method)
          end

          if result == true
            puts check.success_message
          elsif result == false
            puts check.failure_message
          else
            puts "WARN: check was not pure true or false result. Assuming truthy/falsey - this is probably not what you want"
            if result
              puts check.success_message
            else
              puts check.failure_message
            end
          end
        rescue => e
          puts 'ERROR!'
          puts
          puts "  #{e.message}"
          puts
        end
    end
  end


end