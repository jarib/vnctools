require "socket"

module VncTools
  class Server

    class Error < StandardError
    end

    class << self
      def displays
        Dir[File.expand_path("~/.vnc/*.pid")].map { |e| e[/(\d+)\.pid/, 1] }.compact
      end

      def all
        displays.map { |display| new ":#{display}" }
      end

      attr_writer :executable

      def executable
        @executable ||= "tightvncserver"
      end
    end

    attr_reader :display

    def initialize(display = nil)
      @display = display
    end

    def start
      if display
        server(display, *launch_arguments)
      else
        output = server(*launch_arguments)
        @display = output[/desktop is #{host}(\S+)/, 1]
      end
    end

    def stop
      server "-kill", display.to_s
    end

    private

    def launch_arguments
      [] # can be overriden by subclasses
    end

    def server(*args)
      cmd = [self.class.executable, args, '2>&1'].flatten.compact.join ' '
      out = `#{cmd}`

      unless last_status.success?
        raise Error, "could not run #{cmd.inspect}:\n#{out}\ncurrent displays: #{self.class.displays.inspect}"
      end

      out
    end

    def last_status
      $?
    end

    def host
      @host ||= Socket.gethostname
    end
  end # VncServer
end # CukeForker



