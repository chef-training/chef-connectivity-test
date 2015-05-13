module Training

  # A single class representing a "check"; a wrapper around the check method
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Check
    attr_reader :banner,
                :method,
                :success_message,
                :failure_message

    def initialize(method, banner, success_message, failure_message)
      @method = method
      @banner = banner
      @success_message = success_message
      @failure_message = failure_message
    end

    def to_s
      "#<Training::Check #{method}" <<
        " banner: '#{banner}'," <<
        " success: '#{success_message}'," <<
        " failure: '#{failure_message}'" <<
      ">"
    end
  end

end