require "socket"
require 'pathname'

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
        @executable ||= find_executable
      end

      def find_executable
        `which tightvncserver vncserver xtightvncserver`.each_line.map(&:strip).first || 'tightvncserver'
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
        rx = /desktop is #{host}(\S+)/
        @display = output[rx, 1]
        @display or raise Error, "could not find display in #{output.inspect} =~ #{rx.source}"
      end
    end

    def stop(force = false)
      server "-kill", display.to_s
    rescue Error
      force_kill if force
    end

    def force_kill
      if pid_path.exist?
        Process.kill(9, Integer(pid_path.read))
        pid_path.delete if pid_path.exist?
      end
    rescue Errno::ESRCH
      # already gone
      pid_path.delete if pid_path.exist?
    end

    def alive?
      pid_path.exist? && Process.kill(0, Integer(pid_path.read))
    rescue Errno::ESRCH
      pid_path.delete if pid_path.exist?
      false
    end

    def dead?
      !alive?
    end

    def pid_path
      @pid_path ||= Pathname.new(File.expand_path("~/.vnc/#{host}#{display}.pid"))
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
      @host ||= (
        # Java 6 and 7 is inconsistent in its return value, so attempt to read /etc/hostname if possible
        if defined?(JRUBY_VERSION) && File.exist?("/etc/hostname")
          File.read("/etc/hostname").strip
        else
          Socket.gethostname
        end
      )
    end
  end # VncServer
end # CukeForker



